INTERFACE zif_purchase_order_api
  PUBLIC.

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

ENDINTERFACE.
