CLASS zcl_purchase_order_api DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_po_header,
        comp_code TYPE bapi_po_create_header-comp_code,
        doc_type  TYPE bapi_po_create_header-doc_type,
        vendor    TYPE bapi_po_create_header-vendor,
        purch_org TYPE bapi_po_create_header-purch_org,
        pur_group TYPE bapi_po_create_header-pur_group,
      END OF ty_po_header.

    TYPES:
      BEGIN OF ty_po_item,
        po_item   TYPE bapi_po_create_item-po_item,
        material  TYPE bapi_po_create_item-material,
        plant     TYPE bapi_po_create_item-plant,
        stge_loc  TYPE bapi_po_create_item-stge_loc,
        quantity  TYPE bapi_po_create_item-quantity,
        po_unit   TYPE bapi_po_create_item-po_unit,
        net_price TYPE bapi_po_create_item-net_price,
      END OF ty_po_item,
      tty_po_item TYPE STANDARD TABLE OF ty_po_item WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_po_account,
        po_item  TYPE bapi_po_create_account-po_item,
        gl_acct  TYPE bapi_po_create_account-gl_acct,
        cost_ctr TYPE bapi_po_create_account-cost_ctr,
      END OF ty_po_account,
      tty_po_account TYPE STANDARD TABLE OF ty_po_account WITH EMPTY KEY.

    METHODS create_po
      IMPORTING
        is_poheader    TYPE ty_po_header
        it_poitem      TYPE tty_po_item
        it_poaccount   TYPE tty_po_account
      EXPORTING
        ev_ponumber    TYPE bapiekko-po_number
        et_return      TYPE bapirettab.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_purchase_order_api IMPLEMENTATION.
  METHOD create_po.
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
