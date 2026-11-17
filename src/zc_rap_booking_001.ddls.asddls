@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Projection Child View Entity'
@Metadata.allowExtensions: true
@Search.searchable: true
define view entity ZC_RAP_BOOKING_001
  as projection on ZI_RAP_BOOKING_001
{
  key BookingUUID,
      TravelUUID,

      @Search.defaultSearchElement: true
      BookingID,

      BookingDate,

      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_RAP_CUSTOMER_VH', element: 'CustomerID' } }]
      @ObjectModel.text.element: ['CustomerName']
      @Search.defaultSearchElement: true
      CustomerID,
      _Customer.LastName as CustomerName,

      @Consumption.valueHelpDefinition: [{ entity: { name: '/DMO/I_Carrier', element: 'AirlineID' } }]
      CarrierID,

      @Consumption.valueHelpDefinition: [{ entity: { name: '/DMO/I_Connection', element: 'ConnectionID' },
                                          additionalBinding: [{ localElement: 'CarrierID', element: 'AirlineID' }] }]
      ConnectionID,

      FlightDate,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      FlightPrice,

      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Currency', element: 'Currency' } }]
      CurrencyCode,

      BookingStatus,
      LocalLastChangedAt,

      /* Associations */
      _Travel : redirected to parent ZC_RAP_TRAVEL_001,
      _Customer,
      _Carrier,
      _Connection,
      _Currency
}
