CLASS zcl_purchase_order_factory DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS create_api_instance
      RETURNING
        VALUE(ro_po_api) TYPE REF TO zif_purchase_order_api.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_purchase_order_factory IMPLEMENTATION.
  METHOD create_api_instance.
    ro_po_api = NEW zcl_purchase_order_api( ).
  ENDMETHOD.
ENDCLASS.

CLASS ltc_factory_test DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS test_create_instance FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltc_factory_test IMPLEMENTATION.
  METHOD test_create_instance.
    " Act: Call the factory method
    DATA(lo_instance) = zcl_purchase_order_factory=>create_api_instance( ).

    " Assert: Check that a valid object was returned
    cl_abap_unit_assert=>assert_not_initial(
      act = lo_instance
      msg = 'Factory should return a valid instance'
    ).

    " Assert: Check that the object implements the correct interface
    DATA lo_interface_ref TYPE REF TO zif_purchase_order_api.
    lo_interface_ref = lo_instance.
    cl_abap_unit_assert=>assert_not_initial(
      act = lo_interface_ref
      msg = 'Returned instance should implement the API interface'
    ).
  ENDMETHOD.
ENDCLASS.
