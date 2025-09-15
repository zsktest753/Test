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


    TEST-SEAM bapi_po_create.
      CALL FUNCTION 'BAPI_PO_CREATE'
        EXPORTING
          po_header          = ls_poheader
        IMPORTING
          purchase_order_num = ev_ponumber
        TABLES
          po_items           = lt_poitem
          po_item_account    = lt_poaccount
          return             = et_return.
    END-TEST-SEAM.

    " Check for errors
    DATA(lv_has_error) = abap_false.
    LOOP AT et_return INTO DATA(ls_return) WHERE type = 'E' OR type = 'A'.
      lv_has_error = abap_true.
      EXIT.
    ENDLOOP.

    IF lv_has_error = abap_true.
      TEST-SEAM bapi_rollback.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      END-TEST-SEAM.
    ELSE.
      TEST-SEAM bapi_commit.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = lv_wait.
      END-TEST-SEAM.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS ltc_po_api_test DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    DATA:
      go_cut              TYPE REF TO zcl_purchase_order_api,
      gv_commit_called    TYPE abap_bool,
      gv_rollback_called  TYPE abap_bool.

    METHODS:
      setup,
      teardown,
      test_create_po_success FOR TESTING RAISING cx_static_check,
      test_create_po_error   FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltc_po_api_test IMPLEMENTATION.
  METHOD setup.
    " Create a new instance of the class under test for each test
    go_cut = NEW zcl_purchase_order_api( ).
    " Reset flags
    gv_commit_called = abap_false.
    gv_rollback_called = abap_false.
  ENDMETHOD.

  METHOD teardown.
    " Clear the instance
    CLEAR go_cut.
  ENDMETHOD.

  METHOD test_create_po_success.
    " Arrange: Prepare test injections for a successful run
    TEST-INJECTION bapi_po_create.
      " Simulate a successful BAPI call
      ev_ponumber = '4500000001'.
      APPEND VALUE #( type = 'S' message = 'PO created' ) TO et_return.
    END-TEST-INJECTION.

    TEST-INJECTION bapi_commit.
      " If commit is called, set our flag to true
      me->gv_commit_called = abap_true.
    END-TEST-INJECTION.

    TEST-INJECTION bapi_rollback.
      " Rollback should not be called in a success scenario
      cl_abap_unit_assert=>fail( 'Rollback should not be called on success' ).
    END-TEST-INJECTION.

    " Act: Call the method under test
    go_cut->zif_purchase_order_api~create_po(
      EXPORTING
        is_poheader   = VALUE #( comp_code = '1000' )
        it_poitem     = VALUE #( ( po_item = '00010' ) )
        it_poaccount  = VALUE #( ( po_item = '00010' ) )
      IMPORTING
        ev_ponumber   = DATA(lv_po_number)
        et_return     = DATA(lt_return)
    ).

    " Assert: Verify the outcome
    cl_abap_unit_assert=>assert_true(
      act = me->gv_commit_called
      msg = 'Commit should be called on success'
    ).
    cl_abap_unit_assert=>assert_false(
      act = me->gv_rollback_called
      msg = 'Rollback should not be called on success'
    ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4500000001'
      act = lv_po_number
      msg = 'Correct PO number should be returned'
    ).
  ENDMETHOD.

  METHOD test_create_po_error.
    " Arrange: Prepare test injections for a failure
    TEST-INJECTION bapi_po_create.
      " Simulate a failed BAPI call
      APPEND VALUE #( type = 'E' message = 'Vendor not found' ) TO et_return.
    END-TEST-INJECTION.

    TEST-INJECTION bapi_commit.
      " Commit should not be called in an error scenario
      cl_abap_unit_assert=>fail( 'Commit should not be called on error' ).
    END-TEST-INJECTION.

    TEST-INJECTION bapi_rollback.
      " If rollback is called, set our flag to true
      me->gv_rollback_called = abap_true.
    END-TEST-INJECTION.

    " Act: Call the method under test
    go_cut->zif_purchase_order_api~create_po(
      EXPORTING
        is_poheader   = VALUE #( comp_code = '1000' )
        it_poitem     = VALUE #( ( po_item = '00010' ) )
        it_poaccount  = VALUE #( ( po_item = '00010' ) )
      IMPORTING
        ev_ponumber   = DATA(lv_po_number)
        et_return     = DATA(lt_return)
    ).

    " Assert: Verify the outcome
    cl_abap_unit_assert=>assert_true(
      act = me->gv_rollback_called
      msg = 'Rollback should be called on error'
    ).
    cl_abap_unit_assert=>assert_false(
      act = me->gv_commit_called
      msg = 'Commit should not be called on error'
    ).
    cl_abap_unit_assert=>assert_initial(
      act = lv_po_number
      msg = 'PO number should be initial on error'
    ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_return )
      msg = 'Return table should contain one error message'
    ).
  ENDMETHOD.
ENDCLASS.
