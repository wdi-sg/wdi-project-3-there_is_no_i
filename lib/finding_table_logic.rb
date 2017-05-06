module FindingTableLogic
  def set_duration
    @est_duration = 2.hours
    @reservation_allowance = 6
  end

  def determine_table(restaurant, tables_considered, this_customer, start_time_given, block)

    # Find Tables that cannot be used
    affecting_tables = find_affecting_tables(restaurant, start_time_given, block)

    # Filter off Tables that cannot be used
    unless affecting_tables.empty?
      tables_considered = tables_to_consider(tables_considered, affecting_tables)
    end

    # Filter off tables by capacity_total (>= party_size)
    filtered_aval_tables = filter_by_capacity(tables_considered, this_customer)

    # && this.customer.party_size < recommended_table.capacity_minimum...

    p 'SELECTED'
    p filtered_aval_tables[0]

    # Select smallest size available
    recommended_table = filtered_aval_tables[0]
  end

  def find_affecting_tables(restaurant, start_time_given, block)
    end_time_est = start_time_given.utc + block
    date = start_time_given.utc.strftime('%Y-%m-%d')

    # Find all reservations
    all_reservations = Reservation.where(restaurant_id: restaurant.id).where('DATE(start_time) = ?', date).where.not(status: 'checked_out').where.not(status: 'cancelled')

    affecting_reservations = all_reservations.where('start_time < ?', end_time_est).where('end_time > ?', start_time_given)

    # Find Tables that cannot be used
    affecting_tables = []
    affecting_reservations.each do |reservation|
      affecting_tables.push(reservation.table)
    end

    p 'AFFECTING TABLES'
    p affecting_tables
    affecting_tables
  end

  def tables_to_consider(tables_considered, affecting_tables)
    tables_filtered = tables_considered - affecting_tables

    p 'TABLES TO CONSIDER'
    p tables_filtered
    tables_filtered
  end

  def filter_by_capacity(tables_considered, this_customer)
    filtered_aval_tables = []
    tables_considered.each do |table|
      if table.capacity_total >= this_customer.party_size
        filtered_aval_tables.push(table)
      end
    end

    # Sort by smallest table size
    filtered_aval_tables.sort_by!(&:capacity_total)
  end
end
