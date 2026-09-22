/// Controlled vocabulary for user behavior event `action` values.
///
/// The backend does not validate this vocabulary (only the shape of the
/// request), but centralizing the strings here keeps them stable and
/// interpretable by the future persona-extraction job.
class EventActions {
  EventActions._();

  static const String screenOpened = 'screen_opened';
  static const String userLoggedIn = 'user_logged_in';
  static const String userRegistered = 'user_registered';
  static const String accountCreated = 'account_created';
  static const String incomeAdded = 'income_added';
  static const String expenseAdded = 'expense_added';
  static const String installmentAdded = 'installment_added';
  static const String fixedCostAdded = 'fixed_cost_added';
  static const String calendarEventCreated = 'calendar_event_created';
  static const String agentMessageSent = 'agent_message_sent';
  static const String emergencyContactAdded = 'emergency_contact_added';
}
