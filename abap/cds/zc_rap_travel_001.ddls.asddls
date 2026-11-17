@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel Projection Root View Entity'
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZC_RAP_TRAVEL_001
  provider contract transactional_query
  as projection on ZI_RAP_TRAVEL_001
{
  key TravelUUID,

      @Search.defaultSearchElement: true
      TravelID,

      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_RAP_AGENCY_VH', element: 'AgencyID' } }]
      @ObjectModel.text.element: ['AgencyName']
      @Search.defaultSearchElement: true
      AgencyID,
      _Agency.Name       as AgencyName,

      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_RAP_CUSTOMER_VH', element: 'CustomerID' } }]
      @ObjectModel.text.element: ['CustomerName']
      @Search.defaultSearchElement: true
      CustomerID,
      _Customer.LastName as CustomerName,

      BeginDate,
      EndDate,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      BookingFee,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalPrice,

      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Currency', element: 'Currency' } }]
      CurrencyCode,

      @Search.defaultSearchElement: true
      Description,

      OverallStatus,
      LocalLastChangedAt,

      /* Associations */
      _Booking : redirected to composition child ZC_RAP_BOOKING_001,
      _Agency,
      _Customer,
      _Currency
}
