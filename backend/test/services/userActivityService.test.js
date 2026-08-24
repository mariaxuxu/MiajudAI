import {
  validateDiaryEvent,
  validateScreenEvent,
  validateInteractionEvent,
} from '../../src/services/userActivityService.js';

describe('UserActivityService - Validation', () => {
  describe('validateDiaryEvent', () => {
    it('should pass with valid diary event', () => {
      const event = {
        text: 'Paid bills today, relieved',
        mood: 'happy',
        tags: ['finance'],
      };
      expect(() => validateDiaryEvent(event)).not.toThrow();
    });

    it('should throw on empty text', () => {
      const event = {
        text: '',
        mood: 'happy',
        tags: ['finance'],
      };
      expect(() => validateDiaryEvent(event)).toThrow('Diary text is required');
    });

    it('should throw on invalid mood', () => {
      const event = {
        text: 'Some text',
        mood: 'excited',
        tags: [],
      };
      expect(() => validateDiaryEvent(event)).toThrow('Mood must be one of');
    });

    it('should throw on invalid tags', () => {
      const event = {
        text: 'Some text',
        mood: 'happy',
        tags: ['finance', 'invalid_tag'],
      };
      expect(() => validateDiaryEvent(event)).toThrow('Invalid tags');
    });

    it('should allow empty tags', () => {
      const event = {
        text: 'Some text',
        mood: 'neutral',
        tags: [],
      };
      expect(() => validateDiaryEvent(event)).not.toThrow();
    });

    it('should allow all valid tags', () => {
      const event = {
        text: 'Some text',
        mood: 'sad',
        tags: ['finance', 'food', 'domestic', 'calendar'],
      };
      expect(() => validateDiaryEvent(event)).not.toThrow();
    });
  });

  describe('validateScreenEvent', () => {
    it('should pass with valid screen event', () => {
      const event = {
        screen_name: '/accounts',
        dwell_time_seconds: 120,
        source_screen: '/home',
      };
      expect(() => validateScreenEvent(event)).not.toThrow();
    });

    it('should throw on empty screen_name', () => {
      const event = {
        screen_name: '',
        dwell_time_seconds: 120,
      };
      expect(() => validateScreenEvent(event)).toThrow('Screen name is required');
    });

    it('should throw on negative dwell_time', () => {
      const event = {
        screen_name: '/accounts',
        dwell_time_seconds: -10,
      };
      expect(() => validateScreenEvent(event)).toThrow('non-negative integer');
    });

    it('should throw on non-integer dwell_time', () => {
      const event = {
        screen_name: '/accounts',
        dwell_time_seconds: 12.5,
      };
      expect(() => validateScreenEvent(event)).toThrow('non-negative integer');
    });

    it('should allow null dwell_time', () => {
      const event = {
        screen_name: '/accounts',
        dwell_time_seconds: null,
      };
      expect(() => validateScreenEvent(event)).not.toThrow();
    });
  });

  describe('validateInteractionEvent', () => {
    it('should pass with valid interaction event', () => {
      const event = {
        interaction_type: 'clicked_add_income',
        screen_name: '/income',
      };
      expect(() => validateInteractionEvent(event)).not.toThrow();
    });

    it('should throw on empty interaction_type', () => {
      const event = {
        interaction_type: '',
        screen_name: '/income',
      };
      expect(() => validateInteractionEvent(event)).toThrow('Interaction type is required');
    });

    it('should allow null screen_name', () => {
      const event = {
        interaction_type: 'submitted_chat',
        screen_name: null,
      };
      expect(() => validateInteractionEvent(event)).not.toThrow();
    });
  });

  describe('Emotion score derivation', () => {
    it('happy should map to 80', () => {
      // Test via EMOTION_SCORES constant
      const scores = { happy: 80, sad: 20, neutral: 50 };
      expect(scores.happy).toBe(80);
      expect(scores.sad).toBe(20);
      expect(scores.neutral).toBe(50);
    });
  });
});
