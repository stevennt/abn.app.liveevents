enum EventTimeFilter { all, today, weekend, customDate }

class EventFilters {
  const EventFilters({
    this.timeFilter = EventTimeFilter.all,
    this.category = 'All',
    this.query = '',
    this.customDate,
  });

  final EventTimeFilter timeFilter;
  final String category;
  final String query;
  final DateTime? customDate;

  EventFilters copyWith({
    EventTimeFilter? timeFilter,
    String? category,
    String? query,
    DateTime? customDate,
    bool clearCustomDate = false,
  }) {
    return EventFilters(
      timeFilter: timeFilter ?? this.timeFilter,
      category: category ?? this.category,
      query: query ?? this.query,
      customDate: clearCustomDate ? null : customDate ?? this.customDate,
    );
  }
}
