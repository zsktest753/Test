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
