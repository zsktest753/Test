CLASS zcl_purchase_order_api DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_purchase_order_api.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_purchase_order_api IMPLEMENTATION.
  METHOD zif_purchase_order_api~create_po.
    DATA: ls_poheader      TYPE bapi_po_create_header,
          lt_poitem        TYPE STANDARD TABLE OF bapi_po_create_item,
          lt_poaccount     TYPE STANDARD TABLE OF bapi_po_create_account,
          lv_wait          TYPE c LENGTH 1 VALUE 'X'.

    " Map input structures to BAPI structures
    ls_poheader = CORRESPONDING #( is_poheader ).

    lt_poitem = CORRESPONDING #( it_poitem ).

    lt_poaccount = CORRESPONDING #( it_poaccount ).


    CALL FUNCTION 'BAPI_PO_CREATE'
      EXPORTING
        po_header          = ls_poheader
      IMPORTING
        purchase_order_num = ev_ponumber
      TABLES
        po_items           = lt_poitem
        po_item_account    = lt_poaccount
        return             = et_return.

    " Check for errors
    DATA(lv_has_error) = abap_false.
    LOOP AT et_return INTO DATA(ls_return) WHERE type = 'E' OR type = 'A'.
      lv_has_error = abap_true.
      EXIT.
    ENDLOOP.

    IF lv_has_error = abap_true.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = lv_wait.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
