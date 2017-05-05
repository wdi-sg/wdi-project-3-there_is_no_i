module FindingTableLogic

  # Determine Table for New Customer
  def determine_table(restaurant, tables_considered, this_customer, start_time_given, block)

    affecting_tables = find_affecting_tables(restaurant, start_time_given, block)

    unless affecting_tables.empty?
      tables_considered = tables_to_consider(tables_considered, affecting_tables)
    end

    # Filter off tables by capacity_total (>= party_size)
    filtered_aval_tables = filter_by_capacity(tables_considered, this_customer)

    # Select smallest size available
    @chosen_table = filtered_aval_tables[0]
  end

  def find_affecting_tables(restaurant, start_time_given, block)
    end_time_est = start_time_given.utc + block
    date = start_time_given.utc.strftime('%Y-%m-%d')

    # Find all reservations
    all_reservations = Reservation.where(restaurant_id: restaurant.id).where('DATE(start_time) = ?', date)

    # Find Blocked tables of blocked reservations
    affecting_reservations = all_reservations.where('start_time < ?', end_time_est - block).or(all_reservations.where('end_time > ?', start_time_given)).to_a

    # Find Tables that cannot be used
    affecting_tables = []
    affecting_reservations.each do |reservation|
      affecting_tables.push(Table.where('id = ?', reservation.table_id))
    end

    affecting_tables
  end

  def tables_to_consider(tables_considered, affecting_tables)
    tables_considered.select do |table_considered|
      affecting_tables.exclude?(table_considered)
    end
    tables_considered
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
