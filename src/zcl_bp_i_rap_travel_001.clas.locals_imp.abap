CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    CONSTANTS:
      BEGIN OF travel_status,
        open     TYPE c LENGTH 1 VALUE 'O', " Open
        accepted TYPE c LENGTH 1 VALUE 'A', " Accepted
        rejected TYPE c LENGTH 1 VALUE 'X', " Rejected
      END OF travel_status.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS acceptTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~acceptTravel RESULT result.

    METHODS rejectTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~rejectTravel RESULT result.

    METHODS recalcTotalPrice FOR MODIFY
      IMPORTING keys FOR ACTION Travel~recalcTotalPrice RESULT result.

    METHODS setInitialStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Travel~setInitialStatus.

    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Travel~calculateTotalPrice.

    METHODS validateCustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateCustomer.

    METHODS validateDates FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateDates.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_features.
    " Read current status of travel entities
    READ ENTITIES OF zi_rap_travel_001 IN LOCAL MODE
      ENTITY Travel
        FIELDS ( OverallStatus )
        WITH CORRESPONDING #( keys )
      RESULT DATA(travels)
      FAILED failed.

    result = VALUE #( FOR travel IN travels
      LET is_accepted = COND #( WHEN travel-OverallStatus = travel_status-accepted
                                THEN if_abap_behv=>fc-o-disabled
                                ELSE if_abap_behv=>fc-o-enabled )
          is_rejected = COND #( WHEN travel-OverallStatus = travel_status-rejected
                                THEN if_abap_behv=>fc-o-disabled
                                ELSE if_abap_behv=>fc-o-enabled )
      IN ( %tky                 = travel-%tky
           %action-acceptTravel = is_accepted
           %action-rejectTravel = is_rejected ) ).
  ENDMETHOD.

  METHOD get_instance_authorizations.
    " Implementation of authorization checks
    DATA: update_requested TYPE abap_bool,
          delete_requested TYPE abap_bool.

    update_requested = COND #( WHEN requested_authorizations-%update      = if_abap_behv=>mk-on
                                 OR requested_authorizations-%action-Edit = if_abap_behv=>mk-on
                               THEN abap_true ELSE abap_false ).
    delete_requested = COND #( WHEN requested_authorizations-%delete      = if_abap_behv=>mk-on
                               THEN abap_true ELSE abap_false ).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
      APPEND VALUE #( %tky    = <key>-%tky
                      %update = if_abap_behv=>auth-allowed
                      %delete = if_abap_behv=>auth-allowed ) TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD acceptTravel.
    " Set overall status to Accepted ('A')
    MODIFY ENTITIES OF zi_rap_travel_001 IN LOCAL MODE
      ENTITY Travel
        UPDATE FIELDS ( OverallStatus )
        WITH VALUE #( FOR key IN keys ( %tky          = key-%tky
                                        OverallStatus = travel_status-accepted ) )
      FAILED failed
      REPORTED reported.

    " Return the updated travel instances
    READ ENTITIES OF zi_rap_travel_001 IN LOCAL MODE
      ENTITY Travel
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(travels).

    result = VALUE #( FOR travel IN travels ( %tky   = travel-%tky
                                              %param = travel ) ).
  ENDMETHOD.

  METHOD rejectTravel.
    " Set overall status to Rejected ('X')
    MODIFY ENTITIES OF zi_rap_travel_001 IN LOCAL MODE
      ENTITY Travel
        UPDATE FIELDS ( OverallStatus )
        WITH VALUE #( FOR key IN keys ( %tky          = key-%tky
                                        OverallStatus = travel_status-rejected ) )
      FAILED failed
      REPORTED reported.

    " Return the updated travel instances
    READ ENTITIES OF zi_rap_travel_001 IN LOCAL MODE
      ENTITY Travel
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(travels).

    result = VALUE #( FOR travel IN travels ( %tky   = travel-%tky
                                              %param = travel ) ).
  ENDMETHOD.

  METHOD recalcTotalPrice.
    " Read booking fees and associated child booking prices
    READ ENTITIES OF zi_rap_travel_001 IN LOCAL MODE
      ENTITY Travel
        FIELDS ( BookingFee CurrencyCode )
        WITH CORRESPONDING #( keys )
      RESULT DATA(travels).

    READ ENTITIES OF zi_rap_travel_001 IN LOCAL MODE
      ENTITY Travel BY \_Booking
        FIELDS ( FlightPrice CurrencyCode )
        WITH CORRESPONDING #( keys )
      RESULT DATA(bookings).

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      DATA(total) = <travel>-BookingFee.

      LOOP AT bookings ASSIGNING FIELD-SYMBOL(<booking>) WHERE TravelUUID = <travel>-TravelUUID.
        total += <booking>-FlightPrice.
      ENDLOOP.

      MODIFY ENTITIES OF zi_rap_travel_001 IN LOCAL MODE
        ENTITY Travel
          UPDATE FIELDS ( TotalPrice )
          WITH VALUE #( ( %tky       = <travel>-%tky
                          TotalPrice = total ) ).
    ENDLOOP.

    READ ENTITIES OF zi_rap_travel_001 IN LOCAL MODE
      ENTITY Travel
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(updated_travels).

    result = VALUE #( FOR travel IN updated_travels ( %tky   = travel-%tky
                                                      %param = travel ) ).
  ENDMETHOD.

  METHOD setInitialStatus.
    " Set initial status to 'O' (Open) on creation
    READ ENTITIES OF zi_rap_travel_001 IN LOCAL MODE
      ENTITY Travel
        FIELDS ( OverallStatus )
        WITH CORRESPONDING #( keys )
      RESULT DATA(travels).

    DELETE travels WHERE OverallStatus IS NOT INITIAL.
    CHECK travels IS NOT INITIAL.

    MODIFY ENTITIES OF zi_rap_travel_001 IN LOCAL MODE
      ENTITY Travel
        UPDATE FIELDS ( OverallStatus )
        WITH VALUE #( FOR travel IN travels ( %tky          = travel-%tky
                                              OverallStatus = travel_status-open ) ).
  ENDMETHOD.

  METHOD calculateTotalPrice.
    " Trigger price recalculation on modify
    MODIFY ENTITIES OF zi_rap_travel_001 IN LOCAL MODE
      ENTITY Travel
        EXECUTE recalcTotalPrice
        FROM CORRESPONDING #( keys ).
  ENDMETHOD.

  METHOD validateCustomer.
    " Validate that CustomerID is not empty and exists
    READ ENTITIES OF zi_rap_travel_001 IN LOCAL MODE
      ENTITY Travel
        FIELDS ( CustomerID )
        WITH CORRESPONDING #( keys )
      RESULT DATA(travels).

    DATA customers TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.
    customers = CORRESPONDING #( travels DISCARDING DUPLICATES MAPPING customer_id = CustomerID EXCEPT * ).
    DELETE customers WHERE customer_id IS INITIAL.

    IF customers IS NOT INITIAL.
      SELECT FROM /dmo/customer FIELDS customer_id
        FOR ALL ENTRIES IN @customers
        WHERE customer_id = @customers-customer_id
        INTO TABLE @DATA(db_customers).
    ENDIF.

    LOOP AT travels INTO DATA(travel).
      IF travel-CustomerID IS INITIAL OR NOT line_exists( db_customers[ customer_id = travel-CustomerID ] ).
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.
        APPEND VALUE #( %tky                = travel-%tky
                        %state_area         = 'VALIDATE_CUSTOMER'
                        %msg                = new_message_with_text(
                                                severity = if_abap_behv_message=>severity-error
                                                text     = |Customer { travel-CustomerID } is invalid or does not exist.| )
                        %element-CustomerID = if_abap_behv=>mk-on ) TO reported-travel.
      ENDIF.
    LOOP END.
  ENDMETHOD.

  METHOD validateDates.
    " Validate BeginDate < EndDate and BeginDate >= sy-datum
    READ ENTITIES OF zi_rap_travel_001 IN LOCAL MODE
      ENTITY Travel
        FIELDS ( BeginDate EndDate )
        WITH CORRESPONDING #( keys )
      RESULT DATA(travels).

    LOOP AT travels INTO DATA(travel).
      IF travel-EndDate < travel-BeginDate.
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.
        APPEND VALUE #( %tky               = travel-%tky
                        %state_area        = 'VALIDATE_DATES'
                        %msg               = new_message_with_text(
                                               severity = if_abap_behv_message=>severity-error
                                               text     = 'End date cannot be earlier than begin date.' )
                        %element-EndDate   = if_abap_behv=>mk-on ) TO reported-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_Booking DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Booking~calculateTotalPrice.
ENDCLASS.

CLASS lhc_Booking IMPLEMENTATION.

  METHOD calculateTotalPrice.
    " Read parent Travel keys and trigger recalculation
    READ ENTITIES OF zi_rap_travel_001 IN LOCAL MODE
      ENTITY Booking BY \_Travel
        FIELDS ( TravelUUID )
        WITH CORRESPONDING #( keys )
      RESULT DATA(travels).

    MODIFY ENTITIES OF zi_rap_travel_001 IN LOCAL MODE
      ENTITY Travel
        EXECUTE recalcTotalPrice
        FROM VALUE #( FOR travel IN travels ( %tky = travel-%tky ) ).
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZI_RAP_TRAVEL_001 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save_modified REDEFINITION.
ENDCLASS.

CLASS lsc_ZI_RAP_TRAVEL_001 IMPLEMENTATION.

  METHOD save_modified.
    " Generate sequential TravelID for newly created records if not already provided
    IF create-travel IS NOT INITIAL.
      SELECT MAX( travel_id ) FROM zrap_atrav_001 INTO @DATA(max_travel_id).

      LOOP AT create-travel ASSIGNING FIELD-SYMBOL(<new_travel>).
        max_travel_id += 1.
        UPDATE zrap_atrav_001
          SET travel_id = @max_travel_id
          WHERE travel_uuid = @<new_travel>-TravelUUID.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
