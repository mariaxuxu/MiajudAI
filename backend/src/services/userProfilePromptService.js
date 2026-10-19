import { getDatabase } from '../config/database.js';
import { Op } from 'sequelize';
import userActivityService from './userActivityService.js';
import pantryService from './pantryService.js';
import { PANTRY_DOMAINS, PANTRY_DOMAIN_VALUES } from '../utils/constants.js';

// Agent-to-tag mapping
const AGENT_TAGS = {
  luna: 'finance',
  otto: 'food',
  tina: 'domestic',
};

// Prompt-text labels for the pantry block, keyed off the shared domain values so
// a domain added to constants.js can never drift from its label here. The UI
// spells these "Cozinha" / "Doméstico", but this is prose shown to the model,
// not a screen label, so it follows the ticket's lowercase form. The vocabulary
// that must stay shared is the domain value (`food`/`domestic`), not this string.
const PANTRY_DOMAIN_LABELS = {
  [PANTRY_DOMAINS.FOOD]: 'cozinha',
  [PANTRY_DOMAINS.DOMESTIC]: 'doméstico',
};

/**
 * Hard-truncate prompt narrative at the character limit.
 * Shared by buildDiaryContext and buildPantryContext so profile-derived prompt
 * text is clipped the same way wherever it is assembled.
 */
const truncateToLimit = (narrative, charLimit, label, agentType) => {
  if (narrative.length <= charLimit) {
    return narrative;
  }
  console.log(
    `⚠️  ${label} context truncated to ${charLimit} chars for ${agentType}`
  );
  return narrative.substring(0, charLimit - 3) + '...';
};

/**
 * Format diary entry for narrative display
 */
const formatDiaryEntry = (entry) => {
  const daysAgo = Math.floor(
    (new Date() - new Date(entry.created_at)) / (1000 * 60 * 60 * 24)
  );
  const daysLabel =
    daysAgo === 0
      ? 'today'
      : daysAgo === 1
        ? '1 day ago'
        : `${daysAgo} days ago`;

  return `- ${daysLabel} (${entry.mood}): "${entry.text}" [${entry.tags.join(', ')}]`;
};

/**
 * Build digest of older diary entries (7-30 days)
 */
const buildOlderDigest = (entries) => {
  if (!entries || entries.length === 0) {
    return '';
  }

  const moods = entries.map((e) => e.mood);
  const moodCounts = {
    happy: moods.filter((m) => m === 'happy').length,
    sad: moods.filter((m) => m === 'sad').length,
    neutral: moods.filter((m) => m === 'neutral').length,
  };

  const avgEmotionScore =
    entries.reduce((sum, e) => sum + e.emotion_score, 0) / entries.length;

  let trendDescription = '';
  if (avgEmotionScore > 65) {
    trendDescription = 'Generally positive mood';
  } else if (avgEmotionScore < 40) {
    trendDescription = 'Generally stressed or worried';
  } else {
    trendDescription = 'Balanced mood';
  }

  return `Older pattern (7-30 days ago): ${trendDescription}. Moods: ${moodCounts.happy} happy, ${moodCounts.sad} sad, ${moodCounts.neutral} neutral.`;
};

/**
 * Build diary context for an agent
 * @param {number} userId - User ID
 * @param {string} agentType - luna, otto, or tina
 * @param {number} charLimit - Hard character limit (default 1000)
 * @returns {string} Formatted diary context narrative
 */
export const buildDiaryContext = async (userId, agentType, charLimit = 1000) => {
  try {
    const tag = AGENT_TAGS[agentType.toLowerCase()];
    if (!tag) {
      console.warn(`Unknown agent type: ${agentType}`);
      return '';
    }

    // Get recent entries (last 7 days)
    const recent7d = await userActivityService.getDiaryEntriesByTag(
      userId,
      tag,
      10,
      7
    );

    if (!recent7d || recent7d.length === 0) {
      return `User hasn't written diary entries about ${tag} recently. Ask them to share more to help personalize recommendations.`;
    }

    // Format recent entries
    const recentText = recent7d.map((e) => formatDiaryEntry(e)).join('\n');

    // Get older entries (7-30 days) for trend analysis
    const endDate = new Date();
    endDate.setDate(endDate.getDate() - 7);
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - 30);

    const older30d = await userActivityService.getDiaryEntriesForPeriod(
      userId,
      startDate,
      endDate,
      20
    );

    const olderDigest = buildOlderDigest(
      older30d.filter((e) => e.tags && e.tags.includes(tag))
    );

    // Build narrative
    let narrative = `Recent diary context (${tag}):\n${recentText}`;

    if (olderDigest) {
      narrative += `\n\n${olderDigest}`;
    }

    narrative += `\n\nUse this context to personalize your recommendations.`;

    // Truncate if necessary
    narrative = truncateToLimit(narrative, charLimit, 'Diary', agentType);

    console.log(`📖 Diary context built for ${agentType}: ${narrative.length} chars`);
    return narrative;
  } catch (error) {
    console.error(`❌ Error building diary context for ${agentType}:`, error.message);
    return '';
  }
};

/**
 * Build pantry context for an agent
 *
 * The agent→domain mapping is the existing AGENT_TAGS map, gated on the tag
 * actually being a pantry domain. Otto→food and Tina→domestic pass; Luna→finance
 * does not, so she gets no pantry block. Writing a dedicated `{otto, tina}` map
 * here would create the parallel vocabulary the domain glossary forbids.
 *
 * Unlike buildDiaryContext, an empty result is the empty string — not a
 * "user has nothing" sentence. Otto and Tina must not mention a feature the
 * user has not started using.
 *
 * @param {number} userId - User ID
 * @param {string} agentType - luna, otto, or tina
 * @param {number} charLimit - Hard character limit (default 1000)
 * @returns {string} Formatted pantry context, or '' when there is nothing to say
 */
export const buildPantryContext = async (userId, agentType, charLimit = 1000) => {
  try {
    const domain = AGENT_TAGS[agentType.toLowerCase()];
    if (!domain || !PANTRY_DOMAIN_VALUES.includes(domain)) {
      return '';
    }

    // getUserPantry returns every domain (it is the same read GET /pantry does),
    // so the food/domestic split happens here rather than in a second query.
    const rows = await pantryService.getUserPantry(userId);
    const owned = (rows || []).filter((row) => row.PantryItem?.domain === domain);

    // Empty pantry (or only the other domain) produces no block at all.
    if (owned.length === 0) {
      return '';
    }

    const label = PANTRY_DOMAIN_LABELS[domain];
    // Quantity is a pack count with no unit — print the number, never kg/l.
    const list = owned
      .map((row) => `${row.PantryItem.name} (${row.quantity})`)
      .join(', ');

    const narrative = truncateToLimit(
      `Despensa (${label}): ${list}.`,
      charLimit,
      'Pantry',
      agentType
    );

    console.log(`🥫 Pantry context built for ${agentType}: ${narrative.length} chars`);
    return narrative;
  } catch (error) {
    console.error(`❌ Error building pantry context for ${agentType}:`, error.message);
    return '';
  }
};

/**
 * Get quick mood summary (for dashboard/status)
 */
export const getUserMoodSummary = async (userId, daysBack = 7) => {
  try {
    const { DiaryEntry } = getDatabase();
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - daysBack);

    const entries = await DiaryEntry.findAll({
      where: {
        user_id: userId,
        created_at: {
          [Op.gte]: startDate,
        },
      },
      attributes: ['mood', 'emotion_score', 'created_at'],
      order: [['created_at', 'DESC']],
    });

    const moodCounts = {
      happy: 0,
      sad: 0,
      neutral: 0,
    };

    entries.forEach((e) => {
      if (e.mood in moodCounts) {
        moodCounts[e.mood]++;
      }
    });

    const avgEmotionScore =
      entries.length > 0
        ? entries.reduce((sum, e) => sum + e.emotion_score, 0) / entries.length
        : null;

    return {
      entries_count: entries.length,
      mood_distribution: moodCounts,
      avg_emotion_score: avgEmotionScore ? Math.round(avgEmotionScore) : null,
      period_days: daysBack,
    };
  } catch (error) {
    console.error('❌ Error getting mood summary:', error.message);
    return null;
  }
};

export default {
  buildDiaryContext,
  buildPantryContext,
  getUserMoodSummary,
};
