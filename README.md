# ABAP BAPI Wrapper for Purchase Order Creation

## 1. Project Overview

This project provides a robust, professional-grade framework for wrapping the standard SAP BAPI `BAPI_PO_CREATE`. The primary goal is to make this classic BAPI safely and cleanly accessible from modern **ABAP Cloud** environments (Tier 2 development) by encapsulating it within a released API in a lower tier (Tier 3).

The entire solution is designed using **SOLID principles** to ensure it is maintainable, scalable, and easy to test.

## 2. Key Features

- **SOLID Design:** Adheres to object-oriented best practices, particularly the Single Responsibility and Dependency Inversion principles.
- **Decoupled Architecture:** Uses an interface and a factory pattern to decouple the consumer from the concrete implementation.
- **Test-Driven Development (TDD):** Includes a comprehensive suite of **ABAP Unit tests** with 100% logical coverage.
- **Testable Code:** The wrapper class is designed for testability using the `TEST-SEAM` / `TEST-INJECTION` framework to isolate external dependencies.
- **ABAP Cloud Ready:** Specifically designed to bridge the gap between ABAP Cloud tiers, allowing restricted higher-level code to call classic, non-released APIs.

## 3. Component Breakdown

This solution consists of the following ABAP development objects:

| Object Name                  | Type        | Description                                                                                                                                      |
| ---------------------------- | ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| `zif_purchase_order_api`     | Interface   | Defines the public contract for the PO creation service. All consumers should code against this interface.                                       |
| `zcl_purchase_order_api`     | Class       | The concrete implementation of the interface. It contains the logic to call `BAPI_PO_CREATE` and handle transaction control (`COMMIT`/`ROLLBACK`). |
| `zcl_purchase_order_factory` | Class       | A factory class that provides a static method to instantiate the `zcl_purchase_order_api` class, returning it typed to the interface.            |
| `ztest_po_creation`          | Program     | An example report that demonstrates how to use the factory to create a purchase order.                                                             |

## 4. How to Use

To use the framework, you do not need to know the name of the implementing class (`zcl_purchase_order_api`). Instead, you use the factory to get an object that conforms to the public interface (`zif_purchase_order_api`).

```abap
REPORT zr_consumer_example.

START-OF-SELECTION.
  " 1. Get an instance of the service from the factory
  " The lo_po_api variable is typed with the INTERFACE, not the class.
  DATA(lo_po_api) = zcl_purchase_order_factory=>create_api_instance( ).

  " 2. Prepare the data for the new Purchase Order
  DATA(ls_header) = VALUE zif_purchase_order_api=>ty_po_header(
    comp_code = '1000'
    doc_type  = 'NB'
    vendor    = 'YOUR_VENDOR_ID' " <-- Replace with valid master data
    purch_org = '1000'
    pur_group = '001'
  ).

  DATA(lt_items) = VALUE zif_purchase_order_api=>tty_po_item(
    (
      po_item   = '00010'
      material  = 'YOUR_MATERIAL_ID' " <-- Replace with valid master data
      plant     = '1000'
      quantity  = '15'
      po_unit   = 'EA'
      net_price = '120.50'
    )
  ).

  " 3. Call the create method via the interface
  lo_po_api->create_po(
    EXPORTING
      is_poheader   = ls_header
      it_poitem     = lt_items
      it_poaccount  = VALUE #( ) " Optional: Add account assignments if needed
    IMPORTING
      ev_ponumber   = DATA(lv_po_number)
      et_return     = DATA(lt_return)
  ).

  " 4. Check the result
  IF line_exists( lt_return[ type = 'E' ] ) OR line_exists( lt_return[ type = 'A' ] ).
    WRITE: / 'Error creating Purchase Order.'.
    LOOP AT lt_return INTO DATA(ls_return) WHERE type = 'E' OR type = 'A'.
      WRITE: / ls_return-message.
    ENDLOOP.
  ELSE.
    WRITE: / 'Purchase Order created successfully:', lv_po_number.
  ENDIF.
```

## 5. ABAP Cloud Deployment Guide

To use this wrapper in an ABAP Cloud project (e.g., S/4HANA Cloud, Public Edition, or BTP ABAP Environment):

1.  **Package Assignment:** Place all the objects (`zif_*`, `zcl_*`) into a **Tier 3** package. This tier permits the use of classic, non-released SAP APIs.
2.  **Release the API:** The public-facing components must be released for consumption by higher tiers. In the ABAP Development Tools (ADT):
    - Right-click the interface `zif_purchase_order_api`.
    - Go to `Properties` > `API State`.
    - Add the release contract **`C1 - Use in Cloud Development`**.
    - Repeat this process for the factory class `zcl_purchase_order_factory`.
3.  **Consume the API:** You can now create your consumer application (like the example report above) in a **Tier 2** package. It will be able to successfully call the factory and use the released API.

## 6. Testing

This project is delivered with a complete set of unit tests to ensure quality and correctness.

- **To run the tests:**
  1.  In ADT, open the class `zcl_purchase_order_api` or `zcl_purchase_order_factory`.
  2.  Right-click in the editor and select `Run As` > `ABAP Unit Test`.
  3.  The "ABAP Unit" view will open and show the test results.

The tests for `zcl_purchase_order_api` use the `TEST-SEAM` framework to isolate the BAPI calls, meaning they can be run on any system without creating actual purchase orders or requiring valid master data.
