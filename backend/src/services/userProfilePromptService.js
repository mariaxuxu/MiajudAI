import { getDatabase } from '../config/database.js';
import { Op } from 'sequelize';
import userActivityService from './userActivityService.js';

// Agent-to-tag mapping
const AGENT_TAGS = {
  luna: 'finance',
  otto: 'food',
  tina: 'domestic',
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
    if (narrative.length > charLimit) {
      narrative = narrative.substring(0, charLimit - 3) + '...';
      console.log(
        `⚠️  Diary context truncated to ${charLimit} chars for ${agentType}`
      );
    }

    console.log(`📖 Diary context built for ${agentType}: ${narrative.length} chars`);
    return narrative;
  } catch (error) {
    console.error(`❌ Error building diary context for ${agentType}:`, error.message);
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
  getUserMoodSummary,
};
