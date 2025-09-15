REPORT ztest_po_creation.

START-OF-SELECTION.
  DATA: lo_po_api      TYPE REF TO zcl_purchase_order_api,
        ls_po_header   TYPE zcl_purchase_order_api=>ty_po_header,
        lt_po_item     TYPE zcl_purchase_order_api=>tty_po_item,
        lt_po_account  TYPE zcl_purchase_order_api=>tty_po_account,
        lv_po_number   TYPE bapiekko-po_number,
        lt_return      TYPE bapirettab.

  " Instantiate the wrapper class
  CREATE OBJECT lo_po_api.

  " Prepare PO Header Data
  ls_po_header-comp_code = '1000'.
  ls_po_header-doc_type  = 'NB'.
  ls_po_header-vendor    = '100000'. " Replace with a valid vendor
  ls_po_header-purch_org = '1000'.
  ls_po_header-pur_group = '001'.

  " Prepare PO Item Data
  APPEND VALUE #(
    po_item   = '00010'
    material  = 'MATERIAL_01' " Replace with a valid material
    plant     = '1000'
    stge_loc  = '0001'
    quantity  = '10'
    po_unit   = 'EA'
    net_price = '100'
  ) TO lt_po_item.

  " Prepare PO Account Assignment Data
  APPEND VALUE #(
    po_item  = '00010'
    gl_acct  = '400000' " Replace with a valid G/L account
    cost_ctr = '1000'   " Replace with a valid cost center
  ) TO lt_po_account.

  " Call the create_po method
  lo_po_api->create_po(
    EXPORTING
      is_poheader   = ls_po_header
      it_poitem     = lt_po_item
      it_poaccount  = lt_po_account
    IMPORTING
      ev_ponumber   = lv_po_number
      et_return     = lt_return
  ).

  " Display the result
  DATA(lv_has_error) = abap_false.
  LOOP AT lt_return INTO DATA(ls_return) WHERE type = 'E' OR type = 'A'.
    lv_has_error = abap_true.
    WRITE: |Error: { ls_return-message }|.
  ENDLOOP.

  IF lv_has_error = abap_false.
    WRITE: |Purchase Order created successfully: { lv_po_number }|.
  ELSE.
    WRITE: |Purchase Order creation failed.|.
  ENDIF.
