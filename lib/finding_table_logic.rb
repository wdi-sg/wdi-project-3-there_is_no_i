module FindingTableLogic
  def set_duration
    @est_duration = 2.hours
    @reservation_allowance = 2
  end

  def determine_table(restaurant, tables_considered, this_customer, start_time_given, block)

    p 'TABLES CONSIDERED'
    p tables_considered
    p block
    
    # Find Tables that cannot be used
    affecting_tables = find_affecting_tables(restaurant, start_time_given, block)

    # Filter off Tables that cannot be used
    unless affecting_tables.empty?
      tables_considered = tables_to_consider(tables_considered, affecting_tables)
    end

    # Filter off tables by capacity_total (>= party_size)
    filtered_aval_tables = filter_by_capacity(tables_considered, this_customer)

    p 'SELECTED'
    p this_customer
    p filtered_aval_tables[0]

    # Select smallest size available
    recommended_table = filtered_aval_tables[0]
  end

  def find_affecting_tables(restaurant, start_time_given, block)
    # end_time_est = start_time_given.utc + block
    p 'CHECK TIME'
    p start_time_given
    p block

    end_time_est = start_time_given + block
    date = start_time_given.strftime('%Y-%m-%d')

    # Find all reservations
    all_reservations = Reservation.where(restaurant_id: restaurant.id).where('DATE(start_time) = ?', date).where.not(status: 'checked_out').where.not(status: 'cancelled')

    affecting_reservations = all_reservations.where('start_time < ?', end_time_est).where('end_time > ?', start_time_given)

    p all_reservations
    p affecting_reservations

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
    if tables_considered.count > 0
    tables_considered.each do |table|
      if table.capacity_total && table.capacity_total >= this_customer.party_size
        filtered_aval_tables.push(table)
      end
    end
    end

    # Sort by smallest table size
    filtered_aval_tables.sort_by!(&:capacity_total)
  end

  def find_next_customer(table)
    # Next Customer must be able to fit into current table if there is a table
    if table
      filtered_queue = Reservation.where('restaurant_id = ?', @restaurant.id).where('status = ?', 'queuing').where('party_size <= ?', table.capacity_total).where(table_id: nil)
      p '====QUEUE where size <= Table===='
      p filtered_queue
    else
      filtered_queue = []
    end

    # If Potential Next Customers can fit, sort by queue_number
    if filtered_queue.count > 1
      sorted_queue = filtered_queue.sort_by { |customer| customer[:queue_number] }
      p '====QUEUE sorted by q num===='
      p sorted_queue
      sorted_queue.each do |queue|
        p queue.queue_number
      end

      next_customer = sorted_queue[0]

    elsif filtered_queue.count == 1
      next_customer = filtered_queue[0]
    else
      next_customer = nil
    end
  end
end
