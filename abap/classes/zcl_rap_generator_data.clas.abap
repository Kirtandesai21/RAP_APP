CLASS zcl_rap_generator_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zcl_rap_generator_data IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    DATA: travels  TYPE TABLE OF zrap_atrav_001,
          bookings TYPE TABLE OF zrap_abook_001.

    out->write( '---- Starting Data Generation for RAP Application ----' ).

    " Clear existing entries
    DELETE FROM zrap_atrav_001.
    DELETE FROM zrap_dtrav_001.
    DELETE FROM zrap_abook_001.
    DELETE FROM zrap_dbook_001.

    GET TIME STAMP FIELD DATA(current_ts).

    " Sample Travel 1
    DATA(uuid1) = cl_system_uuid=>create_uuid_x16_static( ).
    APPEND VALUE #(
      travel_uuid           = uuid1
      travel_id             = 10000001
      agency_id             = '070001'
      customer_id           = '000001'
      begin_date            = cl_abap_context_info=>get_system_date( ) + 10
      end_date              = cl_abap_context_info=>get_system_date( ) + 20
      booking_fee           = '50.00'
      total_price           = '1150.00'
      currency_code         = 'EUR'
      description           = 'European Summer Business Tour'
      overall_status        = 'O' " Open
      created_by            = sy-uname
      created_at            = current_ts
      last_changed_by       = sy-uname
      last_changed_at       = current_ts
      local_last_changed_at = current_ts
    ) TO travels.

    " Sample Travel 2
    DATA(uuid2) = cl_system_uuid=>create_uuid_x16_static( ).
    APPEND VALUE #(
      travel_uuid           = uuid2
      travel_id             = 10000002
      agency_id             = '070002'
      customer_id           = '000002'
      begin_date            = cl_abap_context_info=>get_system_date( ) + 5
      end_date              = cl_abap_context_info=>get_system_date( ) + 12
      booking_fee           = '30.00'
      total_price           = '880.00'
      currency_code         = 'USD'
      description           = 'North American Tech Conference'
      overall_status        = 'A' " Accepted
      created_by            = sy-uname
      created_at            = current_ts
      last_changed_by       = sy-uname
      last_changed_at       = current_ts
      local_last_changed_at = current_ts
    ) TO travels.

    " Sample Travel 3
    DATA(uuid3) = cl_system_uuid=>create_uuid_x16_static( ).
    APPEND VALUE #(
      travel_uuid           = uuid3
      travel_id             = 10000003
      agency_id             = '070003'
      customer_id           = '000003'
      begin_date            = cl_abap_context_info=>get_system_date( ) - 30
      end_date              = cl_abap_context_info=>get_system_date( ) - 25
      booking_fee           = '25.00'
      total_price           = '450.00'
      currency_code         = 'EUR'
      description           = 'Cancelled Marketing Symposium'
      overall_status        = 'X' " Rejected / Cancelled
      created_by            = sy-uname
      created_at            = current_ts
      last_changed_by       = sy-uname
      last_changed_at       = current_ts
      local_last_changed_at = current_ts
    ) TO travels.

    " Sample Bookings for Travel 1
    APPEND VALUE #(
      booking_uuid          = cl_system_uuid=>create_uuid_x16_static( )
      travel_uuid           = uuid1
      booking_id            = 1
      booking_date          = cl_abap_context_info=>get_system_date( )
      customer_id           = '000001'
      carrier_id            = 'LH'
      connection_id         = '0400'
      flight_date           = cl_abap_context_info=>get_system_date( ) + 10
      flight_price          = '550.00'
      currency_code         = 'EUR'
      booking_status        = 'B'
      local_last_changed_at = current_ts
    ) TO bookings.

    APPEND VALUE #(
      booking_uuid          = cl_system_uuid=>create_uuid_x16_static( )
      travel_uuid           = uuid1
      booking_id            = 2
      booking_date          = cl_abap_context_info=>get_system_date( )
      customer_id           = '000001'
      carrier_id            = 'LH'
      connection_id         = '0401'
      flight_date           = cl_abap_context_info=>get_system_date( ) + 20
      flight_price          = '550.00'
      currency_code         = 'EUR'
      booking_status        = 'B'
      local_last_changed_at = current_ts
    ) TO bookings.

    " Sample Booking for Travel 2
    APPEND VALUE #(
      booking_uuid          = cl_system_uuid=>create_uuid_x16_static( )
      travel_uuid           = uuid2
      booking_id            = 1
      booking_date          = cl_abap_context_info=>get_system_date( )
      customer_id           = '000002'
      carrier_id            = 'AA'
      connection_id         = '0015'
      flight_date           = cl_abap_context_info=>get_system_date( ) + 5
      flight_price          = '850.00'
      currency_code         = 'USD'
      booking_status        = 'B'
      local_last_changed_at = current_ts
    ) TO bookings.

    INSERT zrap_atrav_001 FROM TABLE @travels.
    INSERT zrap_abook_001 FROM TABLE @bookings.

    out->write( |Inserted { lines( travels ) } Travel records.| ).
    out->write( |Inserted { lines( bookings ) } Booking records.| ).
    out->write( '---- Data Generation Completed Successfully ----' ).
  ENDMETHOD.

ENDCLASS.
