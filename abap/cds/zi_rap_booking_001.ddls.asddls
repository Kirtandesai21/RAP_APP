@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Interface Child View Entity'
define view entity ZI_RAP_BOOKING_001
  as select from zrap_abook_001 as Booking
  association to parent ZI_RAP_TRAVEL_001 as _Travel   on $projection.TravelUUID = _Travel.TravelUUID
  association [0..1] to ZI_RAP_CUSTOMER_VH as _Customer on $projection.CustomerID = _Customer.CustomerID
  association [0..1] to /DMO/I_Carrier     as _Carrier  on $projection.CarrierID = _Carrier.AirlineID
  association [0..1] to /DMO/I_Connection  as _Connection on $projection.CarrierID = _Connection.AirlineID
                                                         and $projection.ConnectionID = _Connection.ConnectionID
  association [0..1] to I_Currency         as _Currency on $projection.CurrencyCode = _Currency.Currency
{
  key booking_uuid          as BookingUUID,
      travel_uuid           as TravelUUID,
      booking_id            as BookingID,
      booking_date          as BookingDate,
      customer_id           as CustomerID,
      carrier_id            as CarrierID,
      connection_id         as ConnectionID,
      flight_date           as FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      flight_price          as FlightPrice,
      currency_code         as CurrencyCode,
      booking_status        as BookingStatus,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      /* Associations */
      _Travel,
      _Customer,
      _Carrier,
      _Connection,
      _Currency
}
