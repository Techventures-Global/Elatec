// report 5048933 KVSKBAPurchaseOrder
// {
//     ApplicationArea = KVSKBABasic;
//     Caption = 'Purchase - Order';
//     DefaultLayout = RDLC;
//     PreviewMode = PrintLayout;
// #pragma warning disable AL0835
//     RDLCLayout = 'Base/Layout/KFW Master Document.rdlc';
// #pragma warning restore AL0835
//     UsageCategory = None;
//     WordMergeDataItem = DocHeader;

//     dataset
//     {
//         dataitem(DocHeader; "Purchase Header")
//         {
//             DataItemTableView = sorting("Document Type", "No.") where("Document Type" = const(Order));
//             RequestFilterFields = "No.", "Buy-from Vendor No.", "No. Printed";
//             RequestFilterHeading = 'Purchase - Order';
//             dataitem(CopyLoop; "Integer")
//             {
//                 DataItemTableView = sorting(Number) where(Number = const(1));
//                 dataitem(PageLoop; "Integer")
//                 {
//                     DataItemTableView = sorting(Number) where(Number = const(1));
//                     dataitem(DocHeaderText; KVSKBAPurchaseDocumentText)
//                     {
//                         DataItemLink = "Document Type" = field("Document Type"), "Document No." = field("No.");
//                         DataItemLinkReference = DocHeader;
//                         DataItemTableView = sorting("Document Type", "Document No.", "Document Line No.", Position, "Line No.") order(ascending);

//                         trigger OnAfterGetRecord()
//                         begin
//                             LineCounter += 1;
//                             if not GlobalIsHandled then
//                                 GlobalMasterDoc.CheckAndAddDocTextBuffer
//                                 (
//                                     TempDocHeaderBuffer, TempDocLineBuffer."Line Type"::DocHeaderLine,
//                                     DocLineFormatRec.GetLineFormatDefault(TempDocHeaderBuffer."Report ID", DocLineFormatRec."Line Type"::DocHeaderLine),
//                                     TextBuffer, Text, GetBlobText(), (LineCounter = Count()), (Separator <> Separator::Space), ("Formatted Text".HasValue()));
//                         end;

//                         trigger OnPreDataItem()
//                         begin
//                             TextBuffer := '';
//                             LineCounter := 0;
//                             GlobalIsHandled := false;

//                             DocHeaderText.SetRange(Position, DocHeaderText.Position::"Previous Text");
//                             DocHeaderText.SetRange("Document Line No.", 0);
//                             DocHeaderText.SetRange("Order Print", true);
//                             DocHeaderText.SetFilter("Order Type", '%1|%2', '', DocHeader.KVSKBAPurchaseOrderType);

//                             OnPreDataItemDocHeaderText(TempDocHeaderBuffer, TempDocLineBuffer, GlobalIsHandled, DocHeader, GlobalMasterDoc);
//                         end;

//                         trigger OnPostDataItem()
//                         begin
//                             OnPostDataItemDocHeaderText(TempDocHeaderBuffer, TempDocLineBuffer, DocHeader, GlobalMasterDoc);
//                         end;
//                     }
//                     dataitem(DocLine; "Purchase Line")
//                     {
//                         DataItemLink = "Document Type" = field("Document Type"), "Document No." = field("No.");
//                         DataItemLinkReference = DocHeader;
//                         DataItemTableView = sorting("Document Type", "Document No.", "Line No.");

//                         trigger OnPreDataItem()
//                         begin
//                             CurrReport.Break();
//                         end;
//                     }
//                     dataitem(RoundLoop; "Integer")
//                     {
//                         DataItemTableView = sorting(Number);
//                         PrintOnlyIfDetail = true;
//                         dataitem(HeadLineText; KVSKBAPurchaseDocumentText)
//                         {
//                             DataItemTableView = sorting("Document Type", "Document No.", "Document Line No.", Position, "Line No.");

//                             trigger OnAfterGetRecord()
//                             begin
//                                 LineCounter += 1;
//                                 if not GlobalIsHandled then
//                                     GlobalMasterDoc.CheckAndAddLineTextBuffer
//                                     (
//                                         TempDocHeaderBuffer, TempDocLineBuffer."Table Type"::MainTable,
//                                         DocLine."Line No.", TempDocLineBuffer."Line Type"::PosHeaderLine,
//                                         DocLineFormatRec.GetLineFormatDefaultIndent(TempDocHeaderBuffer."Report ID", DocLineFormatRec."Line Type"::PosHeaderLine, DocLine.KVSKBAIndentation - 1),
//                                         TextBuffer, Text, GetBlobText(), (LineCounter = Count()), (Separator <> Separator::Space), ("Formatted Text".HasValue()));
//                             end;

//                             trigger OnPreDataItem()
//                             begin
//                                 if not DocLine.KVSKBAPrintLine then
//                                     CurrReport.Break();

//                                 HeadLineText.SetRange("Document Type", DocLine."Document Type");
//                                 HeadLineText.SetRange("Document No.", DocLine."Document No.");
//                                 HeadLineText.SetRange("Document Line No.", DocLine."Line No.");
//                                 HeadLineText.SetRange("Order Print", true);
//                                 HeadLineText.SetRange(Position, Position::"Previous Text");
//                                 HeadLineText.SetFilter("Order Type", '%1|%2', '', DocHeader.KVSKBAPurchaseOrderType);

//                                 TextBuffer := '';
//                                 LineCounter := 0;
//                                 GlobalIsHandled := false;
//                                 OnPreDataItemHeadLineText(TempDocHeaderBuffer, TempDocLineBuffer, GlobalIsHandled, DocHeader, DocLine, GlobalMasterDoc);
//                             end;

//                             trigger OnPostDataItem()
//                             begin
//                                 OnPostDataItemHeadLineText(TempDocHeaderBuffer, TempDocLineBuffer, DocHeader, DocLine, GlobalMasterDoc);
//                             end;
//                         }
//                         dataitem(DocLines; "Integer")
//                         {
//                             DataItemTableView = sorting(Number) order(ascending) where(Number = const(1));

//                             trigger OnAfterGetRecord()
//                             begin
//                                 // Init Line Buffer
//                                 OnBeforeInitByPurchaseLine(TempDocLineBuffer, TempDocHeaderBuffer, DocHeader, DocLine, GlobalMasterDoc);
//                                 TempDocLineBuffer.InitByPurchaseLine(TempDocHeaderBuffer."Doc Type", TempDocLineBuffer."Table Type"::MainTable, DocLine);
//                                 OnAfterInitByPurchaseLine(TempDocLineBuffer, TempDocHeaderBuffer, DocHeader, DocLine, GlobalMasterDoc);

//                                 TempDocLineBuffer."Line Format String" :=
//                                     DocLineFormatRec.GetLineFormatForStyleIndent(TempDocHeaderBuffer."Report ID", TempDocLineBuffer."Line Type", DocLine.KVSKBAFontStyle, DocLine.KVSKBAIndentation - 1);
//                                 TempDocLineBuffer."Cross-Reference No." := CrossRefNo;

//                                 OnBeforeAddDocumentLine(TempDocHeaderBuffer, TempDocLineBuffer, DocHeader, DocLine, GlobalMasterDoc);
//                                 GlobalMasterDoc.AddDocLine(TempDocHeaderBuffer, TempDocLineBuffer);
//                                 OnAfterAddDocumentLine(TempDocHeaderBuffer, TempDocLineBuffer, DocHeader, DocLine, GlobalMasterDoc);
//                                 // Retrieve/add item attribute info
//                                 if DocLine.Type = DocLine.Type::Item then begin
//                                     GlobalIsHandled := false;
//                                     OnBeforeAddItemAttributeInfo(TempDocHeaderBuffer, TempDocLineBuffer, GlobalIsHandled, DocHeader, DocLine, GlobalMasterDoc);
//                                     if not GlobalIsHandled then
//                                         KFWMasterDocReportMgt.AddMasterDocItemAttribValueMapping
//                                         (
//                                             GlobalMasterDoc, TempDocHeaderBuffer, TempDocLineBuffer."Table Type"::MainTable,
//                                             DocLine."Line No.", DocLine."No.", DocLine.KVSKBAIndentation);
//                                 end;
//                                 // Retrieve/Add Assembly Info
//                                 // Retrieve/Add Shipment Info
//                                 // Retrieve/Add Tracking Info
//                                 OnAfterAddDocLineInfo(TempDocHeaderBuffer, TempDocLineBuffer, DocHeader, DocLine, GlobalMasterDoc);
//                             end;
//                         }
//                         dataitem(FootLineText; KVSKBAPurchaseDocumentText)
//                         {
//                             DataItemTableView = sorting("Document Type", "Document No.", "Document Line No.", Position, "Line No.");

//                             trigger OnAfterGetRecord()
//                             begin
//                                 LineCounter += 1;
//                                 if not GlobalIsHandled then
//                                     GlobalMasterDoc.CheckAndAddLineTextBuffer
//                                     (
//                                         TempDocHeaderBuffer, TempDocLineBuffer."Table Type"::MainTable,
//                                         DocLine."Line No.", TempDocLineBuffer."Line Type"::PosFooterLine,
//                                         DocLineFormatRec.GetLineFormatDefaultIndent(TempDocHeaderBuffer."Report ID", DocLineFormatRec."Line Type"::PosFooterLine, DocLine.KVSKBAIndentation - 1),
//                                         TextBuffer, Text, GetBlobText(), (LineCounter = Count()), (Separator <> Separator::Space), ("Formatted Text".HasValue()));
//                             end;

//                             trigger OnPreDataItem()
//                             begin
//                                 if not DocLine.KVSKBAPrintLine then
//                                     CurrReport.Break();

//                                 FootLineText.SetRange("Document Type", DocLine."Document Type");
//                                 FootLineText.SetRange("Document No.", DocLine."Document No.");
//                                 FootLineText.SetRange("Document Line No.", DocLine."Line No.");
//                                 FootLineText.SetRange("Order Print", true);
//                                 FootLineText.SetRange(Position, Position::"After Text");
//                                 FootLineText.SetFilter("Order Type", '%1|%2', '', DocHeader.KVSKBAPurchaseOrderType);

//                                 TextBuffer := '';
//                                 LineCounter := 0;
//                                 GlobalIsHandled := false;
//                                 OnPreDataItemFootLineText(TempDocHeaderBuffer, TempDocLineBuffer, GlobalIsHandled, DocHeader, DocLine, GlobalMasterDoc);
//                             end;

//                             trigger OnPostDataItem()
//                             begin
//                                 OnPostDataItemFootLineText(TempDocHeaderBuffer, TempDocLineBuffer, DocHeader, DocLine, GlobalMasterDoc);
//                             end;
//                         } // DI DocLines

//                         trigger OnAfterGetRecord()
//                         begin
//                             if Number = 1 then
//                                 TempPurchLine.FindSet()
//                             else
//                                 TempPurchLine.Next();
//                             DocLine := TempPurchLine;

//                             if not DocLine.KVSKBAPrintLine then
//                                 CurrReport.Skip();

//                             // Check for Page/Block-Break
//                             GlobalIsHandled := false;
//                             GlobalSkipLine := false;
//                             OnBeforeCheckForPageAndBlockBreak(TempDocHeaderBuffer, DocHeader, DocLine, GlobalSkipLine, GlobalIsHandled, GlobalMasterDoc);
//                             if GlobalSkipLine then
//                                 CurrReport.Skip();
//                             if not GlobalIsHandled then begin
//                                 GlobalMasterDoc.CheckForPageBreak(DocLine.KVSKBAPrintPageBreak, DocLine."Line No.");
//                                 if not (DocLine.Type in [DocLine.Type::" "]) then
//                                     GlobalMasterDoc.CheckForNewBlock(DocLine."Line No.");
//                             end;

//                             if not DocHeader."Prices Including VAT" and
//                                (TempPurchLine."VAT Calculation Type" = TempPurchLine."VAT Calculation Type"::"Full VAT")
//                             then
//                                 TempPurchLine."Line Amount" := 0;

//                             if DocLine."Vendor Item No." <> '' then
//                                 CrossRefNo := DocLine."Vendor Item No."
//                             else
//                                 CrossRefNo := DocLine."Item Reference No.";

//                             NNC_TotalLineAmt += TempPurchLine."Line Amount";
//                             NNC_TotalInvDiscAmt += TempPurchLine."Inv. Discount Amount";
//                             NNC_TotalLCY := NNC_TotalLineAmt - NNC_TotalInvDiscAmt;
//                             NNC_VATAmt := TempGlobalVATAmountLine.GetTotalVATAmount();
//                             if DocHeader."Prices Including VAT" then begin
//                                 NNC_TotalExclVAT := NNC_TotalLCY - NNC_VATAmt;
//                                 NNC_TotalInclVAT := NNC_TotalLCY;
//                             end else begin
//                                 NNC_TotalExclVAT := NNC_TotalLCY;
//                                 NNC_TotalInclVAT := NNC_TotalLCY + NNC_VATAmt;
//                             end;
//                             NNC_PmtDiscOnVAT := -VATDiscountAmount;
//                         end;

//                         trigger OnPostDataItem()
//                         begin
//                             // Update VAT Values
//                             TempDocHeaderBuffer."VAT Amount" := TempGlobalVATAmountLine.GetTotalVATAmount();
//                             TempDocHeaderBuffer."Total excl. VAT" := NNC_TotalExclVAT;
//                             TempDocHeaderBuffer."Total incl.VAT" := NNC_TotalInclVAT;
//                             TempDocHeaderBuffer."Total LCY" := NNC_TotalLCY;
//                             TempDocHeaderBuffer."Payment Disc. on VAT" := NNC_PmtDiscOnVAT;
//                             TempDocHeaderBuffer."Total LineAmount" := NNC_TotalLineAmt;
//                             TempDocHeaderBuffer."Inv. Disc. Amount" := NNC_TotalInvDiscAmt;
//                             TempDocHeaderBuffer."VAT Amount Caption" := TempGlobalVATAmountLine.VATAmountText();
//                             TempDocHeaderBuffer."Prepayment Total Amount" := PrepmtTotalAmountInclVAT;
//                             TempDocHeaderBuffer."Prepayment VAT Amount" := PrepmtVATAmount;
//                             OnAfterTransferTotalAmount(TempDocHeaderBuffer, TempGlobalVATAmountLine);

//                             if (PrepmtTotalAmountInclVAT <> 0) and (DocHeader."Prepmt. Payment Terms Code" <> '') then begin
//                                 PrepmtPaymentTerms.Get(DocHeader."Prepmt. Payment Terms Code");
//                                 PrepmtPaymentTerms.TranslateDescription(PrepmtPaymentTerms, DocHeader."Language Code");
//                                 TempDocHeaderBuffer."Prepayment Payment Terms" := PrepmtPaymentTerms.Description;
//                             end;

//                             GlobalMasterDoc.UpdateDocHeader(TempDocHeaderBuffer);

//                             TempPurchLine.DeleteAll();

//                             // Check/Set Shipment Method
//                             GlobalIsHandled := false;
//                             OnBeforeAddShipmentMethod(TempDocHeaderBuffer, GlobalShipmentMethod, GlobalIsHandled, DocHeader, GlobalMasterDoc);
//                             if not GlobalIsHandled then
//                                 if DocHeader."Shipment Method Code" <> '' then begin
//                                     GlobalShipmentMethod.Get(DocHeader."Shipment Method Code");
//                                     GlobalShipmentMethod.TranslateDescription(GlobalShipmentMethod, DocHeader."Language Code");
//                                     GlobalMasterDoc.AddDocTotalText(TempDocHeaderBuffer, TempDocTotalBuffer."Line Type"::TotalText, TempDocHeaderBuffer.GetShipmentMethodCaption() + ' ' + GlobalShipmentMethod.Description);
//                                 end;
//                             OnAfterAddShipmentMethod(TempDocHeaderBuffer, GlobalShipmentMethod, DocHeader, GlobalMasterDoc);

//                             // Check/Set Payment Terms
//                             GlobalIsHandled := false;
//                             OnBeforeAddPaymentTerms(TempDocHeaderBuffer, GlobalPaymentTerms, GlobalIsHandled, DocHeader, GlobalMasterDoc);
//                             if not GlobalIsHandled then
//                                 if DocHeader."Payment Terms Code" <> '' then begin
//                                     GlobalPaymentTerms.Get(DocHeader."Payment Terms Code");
//                                     GlobalPaymentTerms.TranslateDescription(GlobalPaymentTerms, DocHeader."Language Code");
//                                     GlobalMasterDoc.AddDocTotalText(TempDocHeaderBuffer, TempDocTotalBuffer."Line Type"::TotalText, TempDocHeaderBuffer.GetPaymentTermsCaption() + ' ' + GlobalPaymentTerms.Description);
//                                 end;
//                             OnAfterAddPaymentTerms(TempDocHeaderBuffer, GlobalPaymentTerms, DocHeader, GlobalMasterDoc);

//                             // Add Fee Lines
//                         end;

//                         trigger OnPreDataItem()
//                         begin
//                             MoreLines := TempPurchLine.FindLast();
//                             while MoreLines and (TempPurchLine.Description = '') and (TempPurchLine."Description 2" = '') and
//                                   (TempPurchLine."No." = '') and (TempPurchLine.Quantity = 0) and
//                                   (TempPurchLine.Amount = 0)
//                             do
//                                 MoreLines := TempPurchLine.Next(-1) <> 0;

//                             if not MoreLines then
//                                 CurrReport.Break();

//                             TempPurchLine.SetRange("Line No.", 0, TempPurchLine."Line No.");
//                             SetRange(Number, 1, TempPurchLine.Count());
//                         end;
//                     }  // DI RoundLoop
//                     dataitem(DocFooterText; KVSKBAPurchaseDocumentText)
//                     {
//                         DataItemLink = "Document Type" = field("Document Type"), "Document No." = field("No.");
//                         DataItemLinkReference = DocHeader;
//                         DataItemTableView = sorting("Document Type", "Document No.", "Document Line No.", Position, "Line No.") order(ascending);

//                         trigger OnAfterGetRecord()
//                         begin
//                             LineCounter += 1;
//                             if not GlobalIsHandled then
//                                 GlobalMasterDoc.CheckAndAddDocTextBuffer
//                                 (
//                                     TempDocHeaderBuffer, TempDocLineBuffer."Line Type"::DocFooterLine,
//                                     DocLineFormatRec.GetLineFormatDefault(TempDocHeaderBuffer."Report ID", DocLineFormatRec."Line Type"::DocFooterLine),
//                                     TextBuffer, Text, GetBlobText(), (LineCounter = Count()), (Separator <> Separator::Space), ("Formatted Text".HasValue()));
//                         end;

//                         trigger OnPreDataItem()
//                         begin
//                             TextBuffer := '';
//                             LineCounter := 0;
//                             GlobalIsHandled := false;

//                             DocFooterText.SetRange(Position, DocFooterText.Position::"After Text");
//                             DocFooterText.SetRange("Document Line No.", 0);
//                             DocFooterText.SetRange("Order Print", true);
//                             DocFooterText.SetFilter("Order Type", '%1|%2', '', DocHeader.KVSKBAPurchaseOrderType);

//                             OnPreDataItemDocFooterText(TempDocHeaderBuffer, TempDocLineBuffer, GlobalIsHandled, DocHeader, GlobalMasterDoc);
//                         end;

//                         trigger OnPostDataItem()
//                         begin
//                             OnPostDataItemDocFooterText(TempDocHeaderBuffer, TempDocLineBuffer, DocHeader, GlobalMasterDoc);
//                         end;
//                     }
//                     dataitem(DocFooterFinished; "Integer")
//                     {
//                         DataItemTableView = sorting(Number) order(ascending) where(Number = const(1));

//                         trigger OnAfterGetRecord()
//                         begin
//                             OnDocFooterFinished(TempDocHeaderBuffer, DocHeader, GlobalMasterDoc);
//                         end;
//                     }
//                     dataitem(VATSpec; "Integer")
//                     {
//                         DataItemTableView = sorting(Number);

//                         trigger OnAfterGetRecord()
//                         begin
//                             TempGlobalVATAmountLine.GetLine(Number);

//                             GlobalMasterDoc.AddDocVATLine
//                             (
//                                 TempDocHeaderBuffer, TempGlobalVATAmountLine."VAT Identifier", TempGlobalVATAmountLine."VAT %",
//                                 TempGlobalVATAmountLine."VAT Amount", TempGlobalVATAmountLine."VAT Base", TempGlobalVATAmountLine."Line Amount",
//                                 TempGlobalVATAmountLine."Inv. Disc. Base Amount", TempGlobalVATAmountLine."Invoice Discount Amount");
//                         end;

//                         trigger OnPreDataItem()
//                         var
//                             VATIdentifier: Code[20];
//                         begin
//                             GlobalIsHandled := false;
//                             GlobalSkipVATSpecVerification := false;
//                             OnPreDataItemVATSpec(TempDocHeaderBuffer, DocHeader, TempGlobalVATAmountLine, GlobalSkipVATSpecVerification, GlobalIsHandled, GlobalMasterDoc);
//                             if GlobalIsHandled then
//                                 CurrReport.Break();
//                             if not GlobalSkipVATSpecVerification then begin
//                                 if TempGlobalVATAmountLine.Count() <= 1 then
//                                     CurrReport.Break();
//                                 if VATAmount = 0 then
//                                     CurrReport.Break();
//                             end;

//                             case CompanyInfo.KVSKBAPrintVatSpecificonDocs of
//                                 CompanyInfo.KVSKBAPrintVatSpecificonDocs::OnlywithdiffVATIdentifier:
//                                     begin
//                                         TempGlobalVATAmountLine.GetLine(1);
//                                         VATIdentifier := TempGlobalVATAmountLine."VAT Identifier";
//                                         TempGlobalVATAmountLine.SetFilter("VAT Identifier", '<>%1', VATIdentifier);
//                                         if TempGlobalVATAmountLine.IsEmpty then
//                                             CurrReport.Break();
//                                         TempGlobalVATAmountLine.SetRange("VAT Identifier");
//                                     end;
//                                 else begin
//                                     GlobalSkipVATSpecVerification := false;
//                                     OnCasePrintVatSpecificationOnCaseElse(CompanyInfo.KVSKBAPrintVatSpecificonDocs, TempGlobalVATAmountLine, GlobalSkipVATSpecVerification);
//                                     if GlobalSkipVATSpecVerification then
//                                         CurrReport.Break();
//                                 end;
//                             end;

//                             SetRange(Number, 1, TempGlobalVATAmountLine.Count());

//                             GlobalMasterDoc.InitVATTotals();
//                         end;
//                     }
//                     dataitem(VATSpecLCY; "Integer")
//                     {
//                         DataItemTableView = sorting(Number);

//                         trigger OnAfterGetRecord()
//                         begin
//                             TempGlobalVATAmountLine.GetLine(Number);

//                             GlobalVALVATBaseLCY := Round
//                             (
//                                 CurrExchRate.ExchangeAmtFCYToLCY(
//                                 DocHeader."Posting Date", DocHeader."Currency Code",
//                                 TempGlobalVATAmountLine."VAT Base", DocHeader."Currency Factor"));

//                             GlobalVALVATAmountLCY := Round
//                             (
//                                 CurrExchRate.ExchangeAmtFCYToLCY(
//                                 DocHeader."Posting Date", DocHeader."Currency Code",
//                                 TempGlobalVATAmountLine."VAT Amount", DocHeader."Currency Factor"));

//                             GlobalMasterDoc.AddDocVATLineLCY
//                             (
//                                 TempDocHeaderBuffer, TempGlobalVATAmountLine."VAT Identifier", TempGlobalVATAmountLine."VAT %",
//                                 VALExchRate, GlobalVALVATBaseLCY, GlobalVALVATAmountLCY);
//                         end;

//                         trigger OnPreDataItem()
//                         begin
//                             GlobalIsHandled := false;
//                             GlobalSkipVATSpecVerification := false;
//                             OnPreDataItemVATSpecLCY(TempDocHeaderBuffer, DocHeader, TempGlobalVATAmountLine, GlobalSkipVATSpecVerification, GlobalIsHandled, GlobalMasterDoc);
//                             if GlobalIsHandled then
//                                 CurrReport.Break();
//                             if not GlobalSkipVATSpecVerification then
//                                 if (not GLSetup."Print VAT specification in LCY") or
//                                    (DocHeader."Currency Code" = '') or
//                                    (TempGlobalVATAmountLine.GetTotalVATAmount() = 0)
//                                 then
//                                     CurrReport.Break();

//                             SetRange(Number, 1, TempGlobalVATAmountLine.Count());
//                             CurrExchRate.FindCurrency(DocHeader."Posting Date", DocHeader."Currency Code", 1);
//                             VALExchRate := StrSubstNo(ExchangeRateLbl, CurrExchRate."Relational Exch. Rate Amount", CurrExchRate."Exchange Rate Amount");

//                             GlobalMasterDoc.InitVATTotals();
//                         end;
//                     }
//                     dataitem(PrepmtLoop; "Integer")
//                     {
//                         DataItemTableView = sorting(Number) where(Number = filter(1 ..));

//                         trigger OnAfterGetRecord()
//                         begin
//                             if Number = 1 then begin
//                                 if not TempPrepmtInvBuf.FindSet() then
//                                     CurrReport.Break();
//                             end else
//                                 if TempPrepmtInvBuf.Next() = 0 then
//                                     CurrReport.Break();

//                             TempDocLineBuffer.InitLine(TempDocHeaderBuffer, TempDocLineBuffer."Table Type"::PrepaymentTable);
//                             TempDocLineBuffer."Line Type" := TempDocLineBuffer."Line Type"::Default;
//                             TempDocLineBuffer."No." := TempPrepmtInvBuf."G/L Account No.";
//                             TempDocLineBuffer.Description := TempPrepmtInvBuf.Description;
//                             TempDocLineBuffer."Dimension Set ID" := TempPrepmtInvBuf."Dimension Set ID";
//                             if DocHeader."Prices Including VAT" then
//                                 TempDocLineBuffer."Line Amount" := TempPrepmtInvBuf."Amount Incl. VAT"
//                             else
//                                 TempDocLineBuffer."Line Amount" := TempPrepmtInvBuf.Amount;
//                             GlobalMasterDoc.AddDocPrepaymentLine(TempDocLineBuffer);
//                         end;
//                     }
//                     dataitem(PrepmtVATSpec; "Integer")
//                     {
//                         DataItemTableView = sorting(Number);

//                         trigger OnAfterGetRecord()
//                         begin
//                             TempPrepmtVATAmountLine.GetLine(Number);

//                             GlobalMasterDoc.AddDocPrepaymentVATLine(TempDocHeaderBuffer, TempPrepmtVATAmountLine."VAT Identifier", TempPrepmtVATAmountLine."VAT %",
//                               TempPrepmtVATAmountLine."VAT Amount", TempPrepmtVATAmountLine."VAT Base", TempPrepmtVATAmountLine."Line Amount",
//                               TempPrepmtVATAmountLine."Inv. Disc. Base Amount", TempPrepmtVATAmountLine."Invoice Discount Amount");
//                         end;

//                         trigger OnPreDataItem()
//                         begin
//                             SetRange(Number, 1, TempPrepmtVATAmountLine.Count());

//                             GlobalMasterDoc.InitVATTotals();
//                         end;
//                     }
//                 }  // DI PageLoop

//                 trigger OnAfterGetRecord()
//                 var
//                     TempLine: Record "Purchase Line" temporary;
//                     TempPrepmtLine: Record "Purchase Line" temporary;
//                 begin
//                     Clear(TempPurchLine);
//                     Clear(PurchPost);
//                     TempPurchLine.DeleteAll();
//                     TempGlobalVATAmountLine.Reset();
//                     TempGlobalVATAmountLine.DeleteAll();
//                     PurchPost.GetPurchLines(DocHeader, TempPurchLine, 0);
//                     TempPurchLine.CalcVATAmountLines(0, DocHeader, TempPurchLine, TempGlobalVATAmountLine);
//                     TempPurchLine.UpdateVATOnLines(0, DocHeader, TempPurchLine, TempGlobalVATAmountLine);
//                     VATAmount := TempGlobalVATAmountLine.GetTotalVATAmount();
//                     VATDiscountAmount :=
//                       TempGlobalVATAmountLine.GetTotalVATDiscount(DocHeader."Currency Code", DocHeader."Prices Including VAT");

//                     TempPrepmtInvBuf.DeleteAll();
//                     PurchPostPrepmt.GetPurchLines(DocHeader, 0, TempPrepmtLine);
//                     if not TempPrepmtLine.IsEmpty() then begin
//                         PurchPostPrepmt.GetPurchLinesToDeduct(DocHeader, TempLine);
//                         if not TempLine.IsEmpty() then
//                             PurchPostPrepmt.CalcVATAmountLines(DocHeader, TempLine, TempPrepmtVATAmountLineDeduct, 1);
//                     end;
//                     PurchPostPrepmt.CalcVATAmountLines(DocHeader, TempPrepmtLine, TempPrepmtVATAmountLine, 0);
//                     if TempPrepmtVATAmountLine.FindSet() then
//                         repeat
//                             TempPrepmtVATAmountLineDeduct := TempPrepmtVATAmountLine;
//                             if TempPrepmtVATAmountLineDeduct.Find() then begin
//                                 TempPrepmtVATAmountLine."VAT Base" := TempPrepmtVATAmountLine."VAT Base" - TempPrepmtVATAmountLineDeduct."VAT Base";
//                                 TempPrepmtVATAmountLine."VAT Amount" := TempPrepmtVATAmountLine."VAT Amount" - TempPrepmtVATAmountLineDeduct."VAT Amount";
//                                 TempPrepmtVATAmountLine."Amount Including VAT" := TempPrepmtVATAmountLine."Amount Including VAT" -
//                                   TempPrepmtVATAmountLineDeduct."Amount Including VAT";
//                                 TempPrepmtVATAmountLine."Line Amount" := TempPrepmtVATAmountLine."Line Amount" - TempPrepmtVATAmountLineDeduct."Line Amount";
//                                 TempPrepmtVATAmountLine."Inv. Disc. Base Amount" := TempPrepmtVATAmountLine."Inv. Disc. Base Amount" -
//                                   TempPrepmtVATAmountLineDeduct."Inv. Disc. Base Amount";
//                                 TempPrepmtVATAmountLine."Invoice Discount Amount" := TempPrepmtVATAmountLine."Invoice Discount Amount" -
//                                   TempPrepmtVATAmountLineDeduct."Invoice Discount Amount";
//                                 TempPrepmtVATAmountLine."Calculated VAT Amount" := TempPrepmtVATAmountLine."Calculated VAT Amount" -
//                                   TempPrepmtVATAmountLineDeduct."Calculated VAT Amount";
//                                 TempPrepmtVATAmountLine.Modify();
//                             end;
//                         until TempPrepmtVATAmountLine.Next() = 0;
//                     PurchPostPrepmt.UpdateVATOnLines(DocHeader, TempPrepmtLine, TempPrepmtVATAmountLine, 0);
//                     PurchPostPrepmt.BuildInvLineBuffer(DocHeader, TempPrepmtLine, 0, TempPrepmtInvBuf);
//                     PrepmtVATAmount := TempPrepmtVATAmountLine.GetTotalVATAmount();
//                     PrepmtTotalAmountInclVAT := TempPrepmtVATAmountLine.GetTotalAmountInclVAT();

//                     NNC_TotalLCY := 0;
//                     NNC_TotalExclVAT := 0;
//                     NNC_VATAmt := 0;
//                     NNC_TotalInclVAT := 0;
//                     NNC_PmtDiscOnVAT := 0;
//                     NNC_TotalLineAmt := 0;
//                     NNC_TotalInvDiscAmt := 0;

//                     OnAfterGetRecordCopyLoop(TempDocHeaderBuffer, DocHeader, GlobalMasterDoc);
//                 end;
//             }  // DI CopyLoop

//             trigger OnAfterGetRecord()
//             begin
//                 PrintOutput := not CurrReport.Preview;
//                 OnBeforeCheckDocStatusOnAfterGetRecord(DocHeader, GlobalIsHandled, GlobalNoOfRecords, PrintOutput);
//                 if PrintOutput and not GlobalIsHandled
//                 then
//                     if "Prepayment %" = 0 then
//                         if not (Status in [Status::Released, Status::"Pending Prepayment"]) then
//                             FieldError(Status);

//                 OnBeforeCheckDocStructureOnAfterGetRecord(DocHeader, GlobalIsHandled);
//                 if not GlobalIsHandled
//                 then begin
//                     if PurchLib.RunCalcPosNoInPurchLines(DocHeader, false) then
//                         if Status = Status::Open then begin
//                             PurchLib.RunCalcPosNoInPurchLines(DocHeader, true);
//                             Commit();
//                         end;

//                     PurchLib.CheckTotalStructureInPurchLine(DocHeader,
//                         true);        // TRUE: Also check field Totaling in the lines
//                     if PurchSetup.KVSKBACheckPosNoInPurchLines <> PurchSetup.KVSKBACheckPosNoInPurchLines::" " then
//                         PurchLib.CheckPosNoNotEmptyInPurchLine(DocHeader);
//                 end;

//                 CurrReport.Language := GlobLanguage.GetLanguageIdOrDefault("Language Code");
//                 CurrReport.FormatRegion := GlobLanguage.GetFormatRegionOrDefault("Format Region");

//                 GlobalIsHandled := false;
//                 OnBeforeSetLanguageFormatAddress(DocHeader, GlobalIsHandled);
//                 if not GlobalIsHandled then
//                     FormatAddress.SetLanguageCode("Language Code");

//                 if PrintOutput then begin
//                     GlobalMasterDoc.RunArchiveManagement(DocHeader, GlobalArchiveDocument, GlobalLogInteraction, Usage);
//                     GlobalMasterDoc.RunSegManagement(DocHeader, GlobalLogInteraction, Usage);
//                 end;
//                 Mark(true);

//                 GlobalIsHandled := false;
//                 OnBeforeCreateDocumentHeader(TempDocHeaderBuffer, GlobalIsHandled, DocHeader, GlobalMasterDoc);
//                 if not GlobalIsHandled then
//                     // Fill Header Buffer
//                     CreateDocumentHeader();

//                 GlobalIsHandled := false;
//                 OnBeforeCreateDocumentHeading(TempDocHeaderBuffer, GlobalIsHandled, DocHeader, GlobalMasterDoc);
//                 if not GlobalIsHandled then begin
//                     // Fill Heading Buffer
//                     CreateDocumentHeading();
//                     OnAfterCreateDocumentHeading(TempDocHeaderBuffer, DocHeader, GlobalMasterDoc);
//                 end;

//                 GlobalIsHandled := false;
//                 OnBeforeResetLanguageFormatAddress(DocHeader, GlobalIsHandled);
//                 if not GlobalIsHandled then
//                     FormatAddress.SetLanguageCode('');
//             end;

//             trigger OnPostDataItem()
//             begin
//                 GlobalMasterDoc.AddStaticData(TempDocHeaderBuffer);
//             end;

//             trigger OnPreDataItem()
//             begin
//                 GlobalNoOfRecords := Count();
//             end;
//         }  // DI DocHeader

//         dataitem(DocHeader2; Integer)
//         {
//             DataItemTableView = sorting(Number) where(Number = filter(1 ..));
//             dataitem(CopyLoop2; Integer)
//             {
//                 DataItemTableView = sorting(Number);
//                 dataitem(DocDataItems; Integer)
//                 {
//                     DataItemTableView = sorting(Number) where(Number = filter(1 ..));
//                     column(EntryNo; TempDocDataItemBuffer."Entry No.")
//                     {
//                     }
//                     column(DataItemType; TempDocDataItemBuffer."DataItem Type")
//                     {
//                     }
//                     column(TableType; TempDocDataItemBuffer."Table Type")
//                     {
//                     }
//                     column(DocLine_LineNo; TempDocDataItemBuffer."Line No.")
//                     {
//                     }
//                     column(DocLine_DetailLineNo; TempDocDataItemBuffer."Detail Line No.")
//                     {
//                     }
//                     column(DocLine_LineType; TempDocDataItemBuffer."Line Type")
//                     {
//                     }
//                     column(DocLine_Format; TempDocDataItemBuffer."Line Format String")
//                     {
//                     }
//                     column(SortTrigger1; TempDocDataItemBuffer."Sort Trigger 1")
//                     {
//                     }
//                     column(SortTrigger2; TempDocDataItemBuffer."Sort Trigger 2")
//                     {
//                     }
//                     column(SortTrigger3; TempDocDataItemBuffer."Sort Trigger 3")
//                     {
//                     }
//                     column(DocLine_Decimal1; TempDocDataItemBuffer."Decimal 1")
//                     {
//                     }
//                     column(DocLine_Decimal2; TempDocDataItemBuffer."Decimal 2")
//                     {
//                     }
//                     column(DocLine_CarryAmount; TempDocDataItemBuffer."Carry Amount")
//                     {
//                     }
//                     column(NewPageTrigger; TempDocDataItemBuffer."Page Break Trigger")
//                     {
//                     }
//                     column(NewBlockTrigger; TempDocDataItemBuffer."Line Block Trigger")
//                     {
//                     }
//                     column(LineFields; TempDocDataItemBuffer.GetLineFields())
//                     {
//                     }
//                     column(FormattedText; TempDocDataItemBuffer.GetBlobText())
//                     {
//                     }
//                     column(Picture1; TempDocDataItemBuffer."Picture 1")
//                     {
//                     }
//                     column(Picture2; TempDocDataItemBuffer."Picture 2")
//                     {
//                     }
//                     column(Picture3; TempDocDataItemBuffer."Picture 3")
//                     {
//                     }

//                     trigger OnAfterGetRecord()
//                     var
//                         FoundRec: Boolean;
//                     begin
//                         if TempDocHeaderBuffer."No." <> '' then begin
//                             if Number = 1 then
//                                 FoundRec := GlobalMasterDoc.FindFirstDataItem(TempDocDataItemBuffer, TempDocHeaderBuffer, CopyLoop2.Number)
//                             else
//                                 FoundRec := GlobalMasterDoc.FindNextDataItem(TempDocDataItemBuffer, TempDocHeaderBuffer);
//                             if not FoundRec then
//                                 CurrReport.Break();
//                         end else
//                             if Number = 1 then begin
//                                 StaticDataSend := true;
//                                 TempDocDataItemBuffer.Reset();
//                                 if not GlobalMasterDoc.FindStaticData(TempDocDataItemBuffer) then
//                                     CurrReport.Break();
//                             end else
//                                 CurrReport.Break();
//                     end;
//                 }  // DI DocDataItems
//                 column(OutputNo; Number)
//                 {
//                 }

//                 trigger OnAfterGetRecord()
//                 begin
//                     GlobalMasterDoc.SetCopyLoopNo(CopyLoop2.Number);
//                     OnAfterGetRecordCopyLoop2(TempDocHeaderBuffer, DocHeader, GlobalMasterDoc, CopyLoop2.Number);
//                 end;

//                 trigger OnPreDataItem()
//                 begin
//                     if TempDocHeaderBuffer."No." > '' then
//                         SetRange(Number, 1, GlobalMasterDoc.GetNoOfCopies() + 1)
//                     else
//                         SetRange(Number, 0, 0);
//                 end;
//             }  // DI CopyLoop2
//             column(Doc_Scope; TempDocHeaderBuffer."Doc Scope")
//             {
//             }
//             column(Doc_Type; TempDocHeaderBuffer."Doc Type")
//             {
//             }
//             column(Doc_No; TempDocHeaderBuffer."No.")
//             {
//             }
//             column(Doc_NoOcc; TempDocHeaderBuffer."Doc. No. Occurrence")
//             {
//             }
//             column(Doc_VersionNo; TempDocHeaderBuffer."Version No.")
//             {
//             }
//             column(Doc_SortID; TempDocHeaderBuffer."Entry No.")
//             {
//             }

//             trigger OnAfterGetRecord()
//             var
//                 foundRec: Boolean;
//             begin
//                 if not StaticDataSend then begin
//                     if Number = 1 then
//                         foundRec := GlobalMasterDoc.FindFirstHeader(TempDocHeaderBuffer)
//                     else
//                         foundRec := GlobalMasterDoc.FindNextHeader(TempDocHeaderBuffer);
//                     if not foundRec then begin
//                         StaticDataSend := true;
//                         TempDocHeaderBuffer."No." := '';
//                     end;
//                 end else
//                     CurrReport.Break();
//             end;

//             trigger OnPostDataItem()
//             begin
//                 SetPrintCount();
//             end;
//         }  // DI DocHeader2

//         dataitem(AdvOptRef; KVSKBAReqPageAdvOptionValues)
//         {
//             DataItemTableView = sorting("Entry No.");
//             trigger OnPreDataItem()
//             begin
//                 AdvOptRef.SetRange(OptionValue, OptReference);
//                 CurrReport.Break();
//             end;
//         }
//     }

//     requestpage
//     {
//         SaveValues = true;

//         layout
//         {
//             area(Content)
//             {
//                 group(Options)
//                 {
//                     Caption = 'Options';
//                     field(NoOfCopiesField; GlobalNoOfCopies)
//                     {
//                         ApplicationArea = KVSKBABasic;
//                         Caption = 'No. of Copies';
//                         ToolTip = ' ', Locked = true;
//                     }
//                     field(ShowInternalInfoField; GlobalShowInternalInfo)
//                     {
//                         ApplicationArea = KVSKBABasic;
//                         Caption = 'Show Internal Information';
//                         ToolTip = ' ', Locked = true;
//                     }
//                     field(ArchiveDocumentField; GlobalArchiveDocument)
//                     {
//                         ApplicationArea = KVSKBABasic;
//                         Caption = 'Archive Document';
//                         ToolTip = ' ', Locked = true;

//                         trigger OnValidate()
//                         begin
//                             if not GlobalArchiveDocument then
//                                 GlobalLogInteraction := false;
//                         end;
//                     }
//                     field(LogInteractionField; GlobalLogInteraction)
//                     {
//                         ApplicationArea = KVSKBABasic;
//                         Caption = 'Log Interaction';
//                         Enabled = LogInteractionEnable;
//                         ToolTip = ' ', Locked = true;

//                         trigger OnValidate()
//                         begin
//                             if GlobalLogInteraction then
//                                 GlobalArchiveDocument := ArchiveDocumentEnable;
//                         end;
//                     }
//                     field(PrintOnNotePaperField; GlobalPrintOnNotePaper)
//                     {
//                         ApplicationArea = KVSKBABasic;
//                         Caption = 'Print on Letterhead Paper';
//                         ToolTip = ' ', Locked = true;
//                     }
//                     field(PrintOrderCancelationField; GlobalPrintOrderCancelation)
//                     {
//                         ApplicationArea = KVSKBABasic;
//                         Caption = 'Print Cancellation';
//                         ToolTip = ' ', Locked = true;
//                     }
//                 }
//                 group(AdditionalOptions)
//                 {
//                     Caption = 'More Options';
//                     Visible = ShowOption1 or ShowOption2;
//                     grid(Option1)
//                     {
//                         GridLayout = Columns;
//                         ShowCaption = false;
//                         Visible = ShowOption1;
//                         field(CaptionOption1; CaptionOption1Text)
//                         {
//                             ApplicationArea = KVSKBABasic;
//                             Editable = false;
//                             ShowCaption = false;
//                             Visible = ShowOption1;
//                         }
//                         field(OptionValue1; OptionValue1Text)
//                         {
//                             ApplicationArea = KVSKBABasic;
//                             Lookup = true;
//                             ShowCaption = false;
//                             Visible = ShowOption1;
//                             trigger OnLookup(var Text: Text): Boolean
//                             var
//                                 ReqPageAdvOptionHandling: Codeunit KVSKBAReqPageAdvOptionHandling;
//                             begin
//                                 exit(ReqPageAdvOptionHandling.LookupOptionValue(Text, Option1Values));
//                             end;

//                             trigger OnValidate()
//                             var
//                                 ReqPageAdvOptionHandling: Codeunit KVSKBAReqPageAdvOptionHandling;
//                             begin
//                                 ReqPageAdvOptionHandling.ValidateOption1Value(OptReference, OptionValue1Text, OptionValue2Text, Report::KVSKBASalesQuote);
//                             end;
//                         }
//                     }
//                     grid(Option2)
//                     {
//                         GridLayout = Columns;
//                         ShowCaption = false;
//                         Visible = ShowOption2;
//                         field(CaptionOption2; CaptionOption2Text)
//                         {
//                             ApplicationArea = KVSKBABasic;
//                             Editable = false;
//                             ShowCaption = false;
//                             Visible = ShowOption2;
//                         }
//                         field(OptionValue2; OptionValue2Text)
//                         {
//                             ApplicationArea = KVSKBABasic;
//                             Lookup = true;
//                             ShowCaption = false;
//                             Visible = ShowOption2;
//                             trigger OnLookup(var Text: Text): Boolean
//                             var
//                                 ReqPageAdvOptionHandling: Codeunit KVSKBAReqPageAdvOptionHandling;
//                             begin
//                                 exit(ReqPageAdvOptionHandling.LookupOptionValue(Text, Option2Values));
//                             end;

//                             trigger OnValidate()
//                             var
//                                 ReqPageAdvOptionHandling: Codeunit KVSKBAReqPageAdvOptionHandling;
//                             begin
//                                 ReqPageAdvOptionHandling.ValidateOption2Value(OptReference, OptionValue1Text, OptionValue2Text, Report::KVSKBASalesQuote);
//                             end;
//                         }
//                     }
//                 }
//             }
//         }

//         trigger OnInit()
//         begin
//             LogInteractionEnable := true;
//             Usage := Usage::"P.Order";
//         end;

//         trigger OnOpenPage()
//         var
//             ReqPageAdvOptionHandling: Codeunit KVSKBAReqPageAdvOptionHandling;
//         begin
//             OnUpdateRequestPageSettings(DocumentInitEventType::OnOpenPage, DocumentDispSingleInstance.GetRequestPageAlreadyOpen(), GlobalNoOfCopies, GlobalShowInternalInfo, GlobalArchiveDocument, GlobalLogInteraction, GlobalPrintOnNotePaper, GlobalPrintOrderCancelation);
//             // to prevent ongoing initialization
//             if not DocumentDispSingleInstance.GetRequestPageAlreadyOpen() then
//                 DocumentDispSingleInstance.SetRequestPageAlreadyOpen(true);
//             RequestOptionsPage.Update();

//             ReqPageAdvOptionHandling.GetOptions1Values(Option1Values, OptionValue1Text, CaptionOption1Text);
//             if Option1Values.Count > 0 then
//                 ShowOption1 := true;

//             ReqPageAdvOptionHandling.GetOptions2Values(Option2Values, OptionValue2Text, CaptionOption2Text);
//             if Option2Values.Count > 0 then
//                 ShowOption2 := true;
//         end;

//         trigger OnClosePage()
//         var
//             ReqPageAdvOptionHandling: Codeunit KVSKBAReqPageAdvOptionHandling;
//         begin
//             OnUpdateRequestPageSettings(DocumentInitEventType::OnClosePage, DocumentDispSingleInstance.GetRequestPageAlreadyOpen(), GlobalNoOfCopies, GlobalShowInternalInfo, GlobalArchiveDocument, GlobalLogInteraction, GlobalPrintOnNotePaper, GlobalPrintOrderCancelation);

//             OptReference := CreateGuid();
//             if ShowOption1 then
//                 ReqPageAdvOptionHandling.ReturnOption1Value(OptReference, OptionValue1Text);
//             if ShowOption2 then
//                 ReqPageAdvOptionHandling.ReturnOption2Value(OptReference, OptionValue2Text);
//         end;
//     }

//     labels
//     {
//     }

//     trigger OnInitReport()
//     begin
//         if not Evaluate(ReportID, CopyStr(CurrReport.ObjectId(false), 7)) then
//             CurrReport.Quit();

//         GLSetup.Get();
//         CompanyInfo.Get();
//         SalesSetup.Get();
//         PurchSetup.Get();
//     end;

//     trigger OnPreReport()
//     begin
//         CheckLicenceForKBABase();

//         OnUpdateRequestPageSettings(DocumentInitEventType::OnBeforeOnPreReport, DocumentDispSingleInstance.GetRequestPageAlreadyOpen(), GlobalNoOfCopies, GlobalShowInternalInfo, GlobalArchiveDocument, GlobalLogInteraction, GlobalPrintOnNotePaper, GlobalPrintOrderCancelation);

//         if not DocumentDispSingleInstance.GetRequestPage() then
//             if DocumentDispSingleInstance.GetPrintWithLogo() then begin
//                 GlobalPrintOnNotePaper := false;
//                 GlobalShowInternalInfo := false;
//             end;

//         OnUpdateRequestPageSettings(DocumentInitEventType::OnAfterOnPreReport, DocumentDispSingleInstance.GetRequestPageAlreadyOpen(), GlobalNoOfCopies, GlobalShowInternalInfo, GlobalArchiveDocument, GlobalLogInteraction, GlobalPrintOnNotePaper, GlobalPrintOrderCancelation);

//         DocumentDispSingleInstance.SetClientReportID(ReportID);
//         GlobalMasterDoc.InitMaster(ReportID, GlobalNoOfCopies, GlobalPrintOnNotePaper, GlobalShowInternalInfo);
//     end;

//     var
//         CompanyInfo: Record "Company Information";
//         CurrExchRate: Record "Currency Exchange Rate";
//         GLSetup: Record "General Ledger Setup";
//         TempDocDataItemBuffer: Record KVSKBADocumentDataItemBuffer temporary;
//         TempDocHeaderBuffer: Record KVSKBADocumentHeaderBuffer temporary;
//         TempDocHdgBuffer: Record KVSKBADocumentHeadingBuffer temporary;
//         TempDocLineBuffer: Record KVSKBADocumentLineBuffer temporary;
//         DocLineFormatRec: Record KVSKBADocumentLineFormat;
//         TempDocTotalBuffer: Record KVSKBADocumentTotalBuffer temporary;
//         GlobalPaymentTerms: Record "Payment Terms";
//         PrepmtPaymentTerms: Record "Payment Terms";
//         TempPrepmtInvBuf: Record "Prepayment Inv. Line Buffer" temporary;
//         TempPurchLine: Record "Purchase Line" temporary;
//         PurchSetup: Record "Purchases & Payables Setup";
//         RespCenter: Record "Responsibility Center";
//         SalesSetup: Record "Sales & Receivables Setup";
//         GlobalShipmentMethod: Record "Shipment Method";
// #pragma warning disable AL0432
//         TempGlobalVATAmountLine: Record "VAT Amount Line" temporary;
//         TempPrepmtVATAmountLine: Record "VAT Amount Line" temporary;
//         TempPrepmtVATAmountLineDeduct: Record "VAT Amount Line" temporary;
// #pragma warning restore AL0432
//         FormatAddress: Codeunit "Format Address";
//         DocumentDispSingleInstance: Codeunit KVSKBADocDispSingleInstance;
//         GlobalMasterDoc: Codeunit KVSKBAMasterDoc;
//         KFWMasterDocReportMgt: Codeunit KVSKBAMasterDocReportMgt;
//         PurchLib: Codeunit KVSKBAPurchaseLib;
//         ReportUtils: Codeunit KVSKBAReportUtilities;
//         GlobLanguage: Codeunit Language;
//         PurchPost: Codeunit "Purch.-Post";
//         DocumentCountPrinted: Codeunit "Purch.Header-Printed";
//         PurchPostPrepmt: Codeunit "Purchase-Post Prepayments";
//         SegManagement: Codeunit SegManagement;
//         ArchiveDocumentEnable: Boolean;
//         GlobalIsHandled: Boolean;
//         GlobalSkipLine: Boolean;
//         GlobalSkipVATSpecVerification: Boolean;
//         LogInteractionEnable: Boolean;
//         MoreLines: Boolean;
//         PrintAddress: Boolean;
//         PrintOutput: Boolean;
//         ShowOption1, ShowOption2 : Boolean;
//         StaticDataSend: Boolean;
//         CrossRefNo: Code[50];
//         GlobalVALVATAmountLCY: Decimal;
//         GlobalVALVATBaseLCY: Decimal;
//         NNC_PmtDiscOnVAT: Decimal;
//         NNC_TotalExclVAT: Decimal;
//         NNC_TotalInclVAT: Decimal;
//         NNC_TotalInvDiscAmt: Decimal;
//         NNC_TotalLCY: Decimal;
//         NNC_TotalLineAmt: Decimal;
//         NNC_VATAmt: Decimal;
//         PrepmtTotalAmountInclVAT: Decimal;
//         PrepmtVATAmount: Decimal;
//         VATAmount: Decimal;
//         VATDiscountAmount: Decimal;
//         DocumentInitEventType: Enum KVSKBADocumentInitEventType;
//         Usage: Enum "Report Selection Usage";
//         GlobalNoOfRecords: Integer;
//         i: Integer;
//         LineCounter: Integer;
//         ReportID: Integer;
//         ExchangeRateLbl: Label 'Exchange rate: %1/%2', Comment = '%1 is value of field "Relational Exch. Rate Amount" from table "Currency Exchange Rate", %2 is value of field "Exchange Rate Amount" from table "Currency Exchange Rate"';
//         OrderNoLbl: Label 'Order No.';
//         PurchaseOrderCancelationLbl: Label 'Purchase Order Reversal', MaxLength = 80;
//         PurchaseOrderLbl: Label 'Purchase - Order', MaxLength = 80;
//         Option1Values, Option2Values : List of [Text];
//         CaptionOption1Text, CaptionOption2Text, OptionValue1Text, OptionValue2Text : Text;
//         OptReference: Text;
//         TextBuffer: Text;
//         VALExchRate: Text[50];
//         CompanyAddr: array[8] of Text[100];
//         DocumentID: Text[100];
//         PayToAddr: array[8] of Text[100];
//         ShipToAddr: array[8] of Text[100];
//         VendorAddr: array[8] of Text[100];

//     protected var
//         GlobalArchiveDocument: Boolean;
//         GlobalLogInteraction: Boolean;
//         GlobalPrintOnNotePaper: Boolean;
//         GlobalPrintOrderCancelation: Boolean;
//         GlobalShowInternalInfo: Boolean;
//         GlobalNoOfCopies: Integer;

//     local procedure CheckLicenceForKBABase()
//     var
//         KVSKBAModuleMgt: Codeunit KVSKBAModuleMgt;
//     begin
//         KVSKBAModuleMgt.CheckLicenceForKBABase(true);
//     end;

//     internal procedure InitializeRequest(NoOfCopiesFrom: Integer; ShowInternalInfoFrom: Boolean; ArchiveDocumentFrom: Boolean; LogInteractionFrom: Boolean; PrintFrom: Boolean)
//     begin
//         GlobalNoOfCopies := NoOfCopiesFrom;
//         GlobalShowInternalInfo := ShowInternalInfoFrom;
//         GlobalArchiveDocument := ArchiveDocumentFrom;
//         GlobalLogInteraction := LogInteractionFrom;
//         PrintOutput := PrintFrom;
//     end;

//     internal procedure InitLogInteraction()
//     begin
//         GlobalLogInteraction := SegManagement.FindInteractionTemplateCode("Interaction Log Entry Document Type"::"Purch. Ord.") <> '';
//     end;

//     internal procedure InitOptions(OptionNamePar: Text[50])
//     begin
//         // Initialize Option settings
//         if not Evaluate(ReportID, CopyStr(CurrReport.ObjectId(false), 7)) then
//             CurrReport.Quit();
//         if not Evaluate(GlobalNoOfCopies, GlobalMasterDoc.GetDefaultReportOption(ReportID, 'NoOfCopies', OptionNamePar)) then
//             GlobalNoOfCopies := 0;
//         if not Evaluate(GlobalShowInternalInfo, GlobalMasterDoc.GetDefaultReportOption(ReportID, 'ShowInternalInfo', OptionNamePar)) then
//             GlobalShowInternalInfo := false;
//         if not Evaluate(GlobalPrintOnNotePaper, GlobalMasterDoc.GetDefaultReportOption(ReportID, 'PrintOnNotePaper', OptionNamePar)) then
//             GlobalPrintOnNotePaper := false;
//         if not Evaluate(GlobalPrintOrderCancelation, GlobalMasterDoc.GetDefaultReportOption(ReportID, 'PrintOrderCancelation', OptionNamePar)) then
//             GlobalPrintOrderCancelation := false;
//         if not Evaluate(GlobalArchiveDocument, GlobalMasterDoc.GetDefaultReportOption(ReportID, 'ArchiveDocument', OptionNamePar)) then
//             GlobalArchiveDocument := false;
//     end;

//     local procedure CreateDocumentHeader()
//     begin
//         TempDocHeaderBuffer.InitFields(TempDocHeaderBuffer."Doc Scope"::Purchase, TempDocHeaderBuffer."Doc Type"::Order, DocHeader."No.", 0, 0);
//         TempDocHeaderBuffer."Report ID" := ReportID;
//         GlobalMasterDoc.InitCustomFields();

//         TempDocHeaderBuffer."Language Code" := DocHeader."Language Code";
//         TempDocHeaderBuffer."Dimension Set ID" := DocHeader."Dimension Set ID";
//         TempDocHeaderBuffer."Show Internal Info" := GlobalShowInternalInfo;

//         TempDocHeaderBuffer.SetCompanyInfo(GlobalMasterDoc, DocHeader."Responsibility Center");

//         TempDocHeaderBuffer."Doc Caption" := DocCaption();
//         TempDocHeaderBuffer."Doc No. Caption" := OrderNoLbl;
//         TempDocHeaderBuffer."Version Info" := '';
//         TempDocHeaderBuffer."Doc Date" := DocHeader."Document Date";
//         TempDocHeaderBuffer."Price incl. VAT" := DocHeader."Prices Including VAT";
//         TempDocHeaderBuffer."Document ID" := DocumentID;

//         GlobalIsHandled := false;
//         OnBeforeCreateDocumentAddress(TempDocHeaderBuffer, GlobalIsHandled, DocHeader, GlobalMasterDoc);
//         if not GlobalIsHandled then begin
//             FormatAddress.PurchHeaderBuyFrom(VendorAddr, DocHeader);
//             GlobalMasterDoc.AddCustomFieldValue(TempDocHeaderBuffer.GetLayout_DestinationAddressToken(), ReportUtils.GetAddrBlockFromArray(VendorAddr));

//             if RespCenter.Get(DocHeader."Responsibility Center") then
//                 FormatAddress.RespCenter(CompanyAddr, RespCenter)
//             else
//                 FormatAddress.Company(CompanyAddr, CompanyInfo);

//             // Check/Set ShipToAddress
//             GlobalMasterDoc.AddCustomFieldValue(TempDocHeaderBuffer.GetLayout_ShipToAddressToken(), '');
//             PrintAddress := false;
//             FormatAddress.PurchHeaderShipTo(ShipToAddr, DocHeader);
//             for i := 1 to ArrayLen(ShipToAddr) do
//                 if (ShipToAddr[i] <> CompanyAddr[i])
//                 then
//                     PrintAddress := true;
//             if PrintAddress then begin
//                 GlobalMasterDoc.AddCustomFieldValue(TempDocHeaderBuffer.GetLayout_ShipToAddressToken(), ReportUtils.GetAddrBlockFromArray(ShipToAddr));
//                 TempDocHeaderBuffer."Shipment Address Caption" := TempDocHeaderBuffer.GetShipToAddressCaption();
//             end;

//             // Check/Set PayToAddress
//             GlobalMasterDoc.AddCustomFieldValue(TempDocHeaderBuffer.GetLayout_InvoiceToAddressToken(), '');
//             PrintAddress := false;
//             FormatAddress.PurchHeaderPayTo(PayToAddr, DocHeader);
//             for i := 1 to ArrayLen(PayToAddr) do
//                 if PayToAddr[i] <> VendorAddr[i]
//                 then
//                     PrintAddress := true;
//             if PrintAddress then begin
//                 GlobalMasterDoc.AddCustomFieldValue(TempDocHeaderBuffer.GetLayout_InvoiceToAddressToken(), ReportUtils.GetAddrBlockFromArray(PayToAddr));
//                 TempDocHeaderBuffer."Invoice Address Caption" := TempDocHeaderBuffer.GetPayToAddressCaption();
//             end;
//         end;

//         TempDocHeaderBuffer."Currency Code" := DocHeader."Currency Code";
//         if DocHeader."Currency Code" = '' then begin
//             GLSetup.TestField("LCY Code");
//             TempDocHeaderBuffer."Currency Code" := GLSetup."LCY Code";
//         end;
//         TempDocHeaderBuffer."Total Text" := StrSubstNo(TempDocHeaderBuffer.GetTotalCurrency(), TempDocHeaderBuffer."Currency Code");
//         TempDocHeaderBuffer."Total incl. VAT Caption" := StrSubstNo(TempDocHeaderBuffer.GetTotalInclVAT(), TempDocHeaderBuffer."Currency Code");
//         TempDocHeaderBuffer."Total excl. VAT Caption" := StrSubstNo(TempDocHeaderBuffer.GetTotalExclVAT(), TempDocHeaderBuffer."Currency Code");

//         TempDocHeaderBuffer."Shipment Return Date Caption" := TempDocHeaderBuffer.GetExpectedDateCaption();

//         OnBeforeAddDocHeader(TempDocHeaderBuffer, DocHeader, GlobalMasterDoc);

//         GlobalMasterDoc.AddDocHeader(TempDocHeaderBuffer);
//     end;

//     local procedure CreateDocumentHeading()
//     var
//         SalesPurchPerson2_FaxNoLoc: Text[30];
//         SalesPurchPerson2_PhoneNoLoc: Text[30];
//         SalesPurchPerson2_NameLoc: Text[50];
//         SalesPurchPerson_NameLoc: Text[50];
//         SalesPurchPerson2_EmailLoc: Text[80];
//     begin
//         GlobalMasterDoc.AddDocHeading(TempDocHeaderBuffer, TempDocHdgBuffer."Heading Type"::HeadingRight,
//             TempDocHeaderBuffer."Doc No. Caption", TempDocHdgBuffer.FormatBoldWhiteSmoke(),
//             DocHeader."No.", TempDocHdgBuffer.FormatBoldWhiteSmoke(), '', '', '', '', '', '');

//         GlobalMasterDoc.AddDocHeading(TempDocHeaderBuffer, TempDocHdgBuffer."Heading Type"::HeadingRight,
//             TempDocHeaderBuffer.GetVendorCaption(), TempDocHdgBuffer.FormatDefault(),
//             DocHeader."Pay-to Vendor No.", TempDocHdgBuffer.FormatDefault(), '', '', '', '', '', '');

//         if DocHeader."Vendor Order No." <> '' then
//             GlobalMasterDoc.AddDocHeading(TempDocHeaderBuffer, TempDocHdgBuffer."Heading Type"::HeadingRight,
//               TempDocHeaderBuffer.GetYourOrderCaption(), TempDocHdgBuffer.FormatDefault(),
//               DocHeader."Vendor Order No.", TempDocHdgBuffer.FormatDefault(), '', '', '', '', '', '');

//         if DocHeader."Your Reference" <> '' then
//             GlobalMasterDoc.AddDocHeading(TempDocHeaderBuffer, TempDocHdgBuffer."Heading Type"::HeadingRight,
//               CopyStr(DocHeader.FieldCaption(DocHeader."Your Reference"), 1, 100), TempDocHdgBuffer.FormatDefault(),
//               DocHeader."Your Reference", TempDocHdgBuffer.FormatDefault(), '', '', '', '', '', '');

//         if DocHeader."VAT Registration No." <> '' then
//             GlobalMasterDoc.AddDocHeading(TempDocHeaderBuffer, TempDocHdgBuffer."Heading Type"::HeadingRight,
//               CopyStr(DocHeader.FieldCaption(DocHeader."VAT Registration No."), 1, 100), TempDocHdgBuffer.FormatDefault(),
//               DocHeader."VAT Registration No.", TempDocHdgBuffer.FormatDefault(), '', '', '', '', '', '');
//         // Retrieve Contact Person Info
//         GlobalMasterDoc.GetSalesPurchasePersonInformation(KVSKBAPrintSalesPerson::"Salesperson Code1", DocHeader."Purchaser Code", '',
//                                      DocHeader."Assigned User ID", SalesPurchPerson_NameLoc, SalesPurchPerson2_NameLoc,
//                                      SalesPurchPerson2_PhoneNoLoc, SalesPurchPerson2_FaxNoLoc, SalesPurchPerson2_EmailLoc, CurrReport.ObjectId(false));

//         case CompanyInfo.KVSKBADocHeadingStyle of
//             CompanyInfo.KVSKBADocHeadingStyle::ContactInfoTopRight:
//                 begin
//                     if SalesPurchPerson_NameLoc <> '' then
//                         GlobalMasterDoc.AddDocHeading(TempDocHeaderBuffer, TempDocHdgBuffer."Heading Type"::HeadingRight,
//                         TempDocHeaderBuffer.GetPurchasePersonCaption(), TempDocHdgBuffer.FormatDefault(),
//                           SalesPurchPerson_NameLoc, TempDocHdgBuffer.FormatDefault(), '', '', '', '', '', '');

//                     if SalesPurchPerson2_NameLoc <> '' then
//                         GlobalMasterDoc.AddDocHeading(TempDocHeaderBuffer, TempDocHdgBuffer."Heading Type"::HeadingRight,
//                           TempDocHeaderBuffer.GetClerkCaption(), TempDocHdgBuffer.FormatDefault(),
//                           SalesPurchPerson2_NameLoc, TempDocHdgBuffer.FormatDefault(), '', '', '', '', '', '');

//                     if SalesPurchPerson2_PhoneNoLoc <> '' then
//                         GlobalMasterDoc.AddDocHeading(TempDocHeaderBuffer, TempDocHdgBuffer."Heading Type"::HeadingRight,
//                           TempDocHeaderBuffer.GetPhoneNoCaption(), TempDocHdgBuffer.FormatDefault(),
//                           SalesPurchPerson2_PhoneNoLoc, TempDocHdgBuffer.FormatDefault(), '', '', '', '', '', '');

//                     if SalesPurchPerson2_FaxNoLoc <> '' then
//                         GlobalMasterDoc.AddDocHeading(TempDocHeaderBuffer, TempDocHdgBuffer."Heading Type"::HeadingRight,
//                           TempDocHeaderBuffer.GetFaxNoCaption(), TempDocHdgBuffer.FormatDefault(),
//                           SalesPurchPerson2_FaxNoLoc, TempDocHdgBuffer.FormatDefault(), '', '', '', '', '', '');

//                     if SalesPurchPerson2_EmailLoc <> '' then
//                         GlobalMasterDoc.AddDocHeading(TempDocHeaderBuffer, TempDocHdgBuffer."Heading Type"::HeadingRight,
//                           TempDocHeaderBuffer.GetEmailCaption(), TempDocHdgBuffer.FormatDefault(),
//                           SalesPurchPerson2_EmailLoc, TempDocHdgBuffer.FormatDefault(), '', '', '', '', '', '');

// #pragma warning disable AL0432
//                     if TempDocHeaderBuffer."Company Home Page" <> '' then
// #pragma warning restore AL0432
//                         GlobalMasterDoc.AddDocHeading(TempDocHeaderBuffer, TempDocHdgBuffer."Heading Type"::HeadingRight,
//                           TempDocHeaderBuffer.GetHomePageCaption(), TempDocHdgBuffer.FormatDefault(),
// #pragma warning disable AL0432
//                           TempDocHeaderBuffer."Company Home Page", TempDocHdgBuffer.FormatDefault(), '', '', '', '', '', '');
// #pragma warning restore AL0432
//                 end;

//             CompanyInfo.KVSKBADocHeadingStyle::ContactInfoLine5:
//                 begin
//                     // Contact Info Line (5 Columns)
// #pragma warning disable AL0432
//                     if TempDocHeaderBuffer."Company Home Page" <> '' then
// #pragma warning restore AL0432
//                         GlobalMasterDoc.AddDocHeading(TempDocHeaderBuffer, TempDocHdgBuffer."Heading Type"::HeadingRight,
//                           TempDocHeaderBuffer.GetHomePageCaption(), TempDocHdgBuffer.FormatDefault(),
// #pragma warning disable AL0432
//                           TempDocHeaderBuffer."Company Home Page", TempDocHdgBuffer.FormatDefault(), '', '', '', '', '', '');
// #pragma warning restore AL0432
//                     // 5 Columns Heading/Line
//                     GlobalMasterDoc.AddDocHeading(TempDocHeaderBuffer, TempDocHdgBuffer."Heading Type"::HeadingLine5,
//                       TempDocHeaderBuffer.GetPurchasePersonCaption(), TempDocHdgBuffer.FormatBoldWhiteSmoke(),
//                       TempDocHeaderBuffer.GetClerkCaption(), TempDocHdgBuffer.FormatBoldWhiteSmoke(),
//                       TempDocHeaderBuffer.GetPhoneNoCaption(), TempDocHdgBuffer.FormatBoldWhiteSmoke(),
//                       TempDocHeaderBuffer.GetFaxNoCaption(), TempDocHdgBuffer.FormatBoldWhiteSmoke(),
//                       TempDocHeaderBuffer.GetEmailCaption(), TempDocHdgBuffer.FormatBoldWhiteSmoke());

//                     GlobalMasterDoc.AddDocHeading(TempDocHeaderBuffer, TempDocHdgBuffer."Heading Type"::HeadingLine5,
//                       SalesPurchPerson_NameLoc, '',
//                       SalesPurchPerson2_NameLoc, '',
//                       SalesPurchPerson2_PhoneNoLoc, '',
//                       SalesPurchPerson2_FaxNoLoc, '',
//                       SalesPurchPerson2_EmailLoc, '');
//                 end;
//         end;
//         // CASE HeadingStyle
//         // Insert Blanket Order No.
//         if CheckBlanketOrderNo(DocHeader."No.") <> '' then
//             GlobalMasterDoc.AddDocHeading(TempDocHeaderBuffer, TempDocHdgBuffer."Heading Type"::HeadingRight,
//               TempDocHeaderBuffer.GetDocHeaderBlanketOrderNoCaption(), TempDocHdgBuffer.FormatDefault(),
//               CheckBlanketOrderNo(DocHeader."No."), TempDocHdgBuffer.FormatDefault(), '', '', '', '', '', '');
//         // Shipment No.
//     end;

//     local procedure SetPrintCount()
//     var
//         DocHeaderLoc: Record "Purchase Header";
//     begin
//         if not IsReportInPreviewMode() then begin
//             DocHeaderLoc.Copy(DocHeader);
//             if DocHeaderLoc.FindSet() then
//                 repeat
//                     DocumentCountPrinted.Run(DocHeaderLoc);
//                 until DocHeaderLoc.Next() = 0;
//         end;
//     end;

//     local procedure IsReportInPreviewMode(): Boolean
//     var
//         MailManagement: Codeunit "Mail Management";
//     begin
//         exit(CurrReport.Preview or MailManagement.IsHandlingGetEmailBody());
//     end;

//     local procedure DocCaption(): Text[80]
//     begin
//         if GlobalPrintOrderCancelation then
//             exit(PurchaseOrderCancelationLbl);
//         exit(PurchaseOrderLbl);
//     end;

//     local procedure CheckBlanketOrderNo(DocHeaderNoPar: Code[20]): Text[50]
//     var
//         PurchaseLineLoc: Record "Purchase Line";
//         xRecBlanketOrderNoLoc: Text[50];
//     begin
//         // Check if Purch. Order Lines from the same Blanket Purch. Order
//         Clear(xRecBlanketOrderNoLoc);

//         PurchaseLineLoc.Reset();
//         PurchaseLineLoc.SetRange("Document No.", DocHeaderNoPar);
//         PurchaseLineLoc.SetFilter("Blanket Order No.", '<>%1', '');
//         if PurchaseLineLoc.FindSet() then
//             repeat
//                 if (xRecBlanketOrderNoLoc <> '') and (xRecBlanketOrderNoLoc <> PurchaseLineLoc."Blanket Order No.") then
//                     exit('');
//                 xRecBlanketOrderNoLoc := PurchaseLineLoc."Blanket Order No.";
//             until PurchaseLineLoc.Next() = 0;

//         exit(xRecBlanketOrderNoLoc);
//     end;

//     // RequestPage
//     [IntegrationEvent(true, false)]
//     local procedure OnUpdateRequestPageSettings(InitEventType: Enum KVSKBADocumentInitEventType; RequestPageAlreadyOpen: Boolean; var NoOfCopies: Integer; var ShowInternalInfo: Boolean; var ArchiveDocument: Boolean; var LogInteraction: Boolean; var PrintOnNotePaper: Boolean; var PrintOrderCancelation: Boolean)
//     begin
//     end;

//     // Document Header/Heading

//     [IntegrationEvent(true, false)]
//     local procedure OnBeforeCheckDocStatusOnAfterGetRecord(var DocumentHeader: Record "Purchase Header"; var Handled: Boolean; var NoOfRecords: Integer; PrintOutput: Boolean)
//     begin
//     end;

//     [IntegrationEvent(true, false)]
//     local procedure OnBeforeCheckDocStructureOnAfterGetRecord(var DocumentHeader: Record "Purchase Header"; var Handled: Boolean)
//     begin
//     end;

//     [IntegrationEvent(true, false)]
//     local procedure OnBeforeCreateDocumentHeader(var DocumentHeaderBuffer: Record KVSKBADocumentHeaderBuffer temporary; var Handled: Boolean; var DocumentHeader: Record "Purchase Header"; var MasterDoc: Codeunit KVSKBAMasterDoc)
//     begin
//     end;

//     [IntegrationEvent(true, false)]
//     local procedure OnBeforeCreateDocumentAddress(var DocumentHeaderBuffer: Record KVSKBADocumentHeaderBuffer temporary; var Handled: Boolean; var DocumentHeader: Record "Purchase Header"; var MasterDoc: Codeunit KVSKBAMasterDoc)
//     begin
//     end;

//     [IntegrationEvent(true, false)]
//     local procedure OnBeforeAddDocHeader(var DocumentHeaderBuffer: Record KVSKBADocumentHeaderBuffer temporary; var DocumentHeader: Record "Purchase Header"; var MasterDoc: Codeunit KVSKBAMasterDoc)
//     begin
//     end;

//     [IntegrationEvent(true, false)]
//     local procedure OnBeforeCreateDocumentHeading(var DocumentHeaderBuffer: Record KVSKBADocumentHeaderBuffer temporary; var Handled: Boolean; var DocumentHeader: Record "Purchase Header"; var MasterDoc: Codeunit KVSKBAMasterDoc)
//     begin
//     end;

//     [IntegrationEvent(true, false)]
//     local procedure OnAfterCreateDocumentHeading(var DocumentHeaderBuffer: Record KVSKBADocumentHeaderBuffer temporary; var DocumentHeader: Record "Purchase Header"; var MasterDoc: Codeunit KVSKBAMasterDoc)
//     begin
//     end;

//     // Document Text

//     [IntegrationEvent(true, false)]
//     local procedure OnPreDataItemDocHeaderText(var DocumentHeaderBuffer: Record KVSKBADocumentHeaderBuffer temporary; var DocumentLineBuffer: Record KVSKBADocumentLineBuffer temporary; var isHandled: Boolean; var DocumentHeader: Record "Purchase Header"; var MasterDoc: Codeunit KVSKBAMasterDoc)
//     begin
//     end;

//     [IntegrationEvent(true, false)]
//     local procedure OnPostDataItemDocHeaderText(var DocumentHeaderBuffer: Record KVSKBADocumentHeaderBuffer temporary; var DocumentLineBuffer: Record KVSKBADocumentLineBuffer temporary; var DocumentHeader: Record "Purchase Header"; var MasterDoc: Codeunit KVSKBAMasterDoc)
//     begin
//     end;

//     [IntegrationEvent(true, false)]
//     local procedure OnPreDataItemDocFooterText(var DocumentHeaderBuffer: Record KVSKBADocumentHeaderBuffer temporary; var DocumentLineBuffer: Record KVSKBADocumentLineBuffer temporary; var isHandled: Boolean; var DocumentHeader: Record "Purchase Header"; var MasterDoc: Codeunit KVSKBAMasterDoc)
//     begin
//     end;

//     [IntegrationEvent(true, false)]
//     local procedure OnPostDataItemDocFooterText(var DocumentHeaderBuffer: Record KVSKBADocumentHeaderBuffer temporary; var DocumentLineBuffer: Record KVSKBADocumentLineBuffer temporary; var DocumentHeader: Record "Purchase Header"; var MasterDoc: Codeunit KVSKBAMasterDoc)
//     begin
//     end;

//     [IntegrationEvent(true, false)]
//     local procedure OnDocFooterFinished(var DocumentHeaderBuffer: Record KVSKBADocumentHeaderBuffer temporary; var DocumentHeader: Record "Purchase Header"; var MasterDoc: Codeunit KVSKBAMasterDoc)
//     begin
//     end;

//     // Document Lines

//     [IntegrationEvent(false, false)]
//     local procedure OnBeforeCheckForPageAndBlockBreak(var DocumentHeaderBuffer: Record KVSKBADocumentHeaderBuffer temporary; var DocumentHeader: Record "Purchase Header"; var DocumentLine: Record "Purchase Line"; var skipLine: Boolean; var isHandled: Boolean; var MasterDoc: Codeunit KVSKBAMasterDoc)
//     begin
//     end;

//     [IntegrationEvent(false, false)]
//     local procedure OnBeforeAddDocumentLine(var DocumentHeaderBuffer: Record KVSKBADocumentHeaderBuffer temporary; var DocumentLineBuffer: Record KVSKBADocumentLineBuffer temporary; var DocumentHeader: Record "Purchase Header"; var DocumentLine: Record "Purchase Line"; var MasterDoc: Codeunit KVSKBAMasterDoc)
//     begin
//     end;

//     [IntegrationEvent(false, false)]
//     local procedure OnAfterAddDocumentLine(var DocumentHeaderBuffer: Record KVSKBADocumentHeaderBuffer temporary; var DocumentLineBuffer: Record KVSKBADocumentLineBuffer temporary; var DocumentHeader: Record "Purchase Header"; var DocumentLine: Record "Purchase Line"; var MasterDoc: Codeunit KVSKBAMasterDoc)
//     begin
//     end;

//     [IntegrationEvent(false, false)]
//     local procedure OnBeforeInitByPurchaseLine(var DocumentLineBuffer: Record KVSKBADocumentLineBuffer temporary; var DocumentHeaderBuffer: Record KVSKBADocumentHeaderBuffer temporary; var DocumentHeader: Record "Purchase Header"; var DocumentLine: Record "Purchase Line"; var MasterDoc: Codeunit KVSKBAMasterDoc)
//     begin
//     end;

//     [IntegrationEvent(false, false)]
//     local procedure OnAfterInitByPurchaseLine(var DocumentLineBuffer: Record KVSKBADocumentLineBuffer temporary; var DocumentHeaderBuffer: Record KVSKBADocumentHeaderBuffer temporary; var DocumentHeader: Record "Purchase Header"; var DocumentLine: Record "Purchase Line"; var MasterDoc: Codeunit KVSKBAMasterDoc)
//     begin
//     end;

//     [IntegrationEvent(false, false)]
//     local procedure OnBeforeAddItemAttributeInfo(var DocumentHeaderBuffer: Record KVSKBADocumentHeaderBuffer temporary; var DocumentLineBuffer: Record KVSKBADocumentLineBuffer temporary; var isHandled: Boolean; var DocumentHeader: Record "Purchase Header"; var DocumentLine: Record "Purchase Line"; var MasterDoc: Codeunit KVSKBAMasterDoc)
//     begin
//     end;

//     [IntegrationEvent(false, false)]
//     local procedure OnAfterAddDocLineInfo(var DocumentHeaderBuffer: Record KVSKBADocumentHeaderBuffer temporary; var DocumentLineBuffer: Record KVSKBADocumentLineBuffer temporary; var DocumentHeader: Record "Purchase Header"; var DocumentLine: Record "Purchase Line"; var MasterDoc: Codeunit KVSKBAMasterDoc)
//     begin
//     end;

//     // Document Line Text

//     [IntegrationEvent(true, false)]
//     local procedure OnPreDataItemHeadLineText(var DocumentHeaderBuffer: Record KVSKBADocumentHeaderBuffer temporary; var DocumentLineBuffer: Record KVSKBADocumentLineBuffer temporary; var isHandled: Boolean; var DocumentHeader: Record "Purchase Header"; var DocumentLine: Record "Purchase Line"; var MasterDoc: Codeunit KVSKBAMasterDoc)
//     begin
//     end;

//     [IntegrationEvent(true, false)]
//     local procedure OnPostDataItemHeadLineText(var DocumentHeaderBuffer: Record KVSKBADocumentHeaderBuffer temporary; var DocumentLineBuffer: Record KVSKBADocumentLineBuffer temporary; var DocumentHeader: Record "Purchase Header"; var DocumentLine: Record "Purchase Line"; var MasterDoc: Codeunit KVSKBAMasterDoc)
//     begin
//     end;

//     [IntegrationEvent(true, false)]
//     local procedure OnPreDataItemFootLineText(var DocumentHeaderBuffer: Record KVSKBADocumentHeaderBuffer temporary; var DocumentLineBuffer: Record KVSKBADocumentLineBuffer temporary; var isHandled: Boolean; var DocumentHeader: Record "Purchase Header"; var DocumentLine: Record "Purchase Line"; var MasterDoc: Codeunit KVSKBAMasterDoc)
//     begin
//     end;

//     [IntegrationEvent(true, false)]
//     local procedure OnPostDataItemFootLineText(var DocumentHeaderBuffer: Record KVSKBADocumentHeaderBuffer temporary; var DocumentLineBuffer: Record KVSKBADocumentLineBuffer temporary; var DocumentHeader: Record "Purchase Header"; var DocumentLine: Record "Purchase Line"; var MasterDoc: Codeunit KVSKBAMasterDoc)
//     begin
//     end;

//     // Document Totals

//     [IntegrationEvent(false, false)]
//     local procedure OnBeforeAddShipmentMethod(var DocumentHeaderBuffer: Record KVSKBADocumentHeaderBuffer temporary; var ShipmentMethod: Record "Shipment Method"; var isHandled: Boolean; var DocumentHeader: Record "Purchase Header"; var MasterDoc: Codeunit KVSKBAMasterDoc);
//     begin
//     end;

//     [IntegrationEvent(false, false)]
//     local procedure OnAfterAddShipmentMethod(var DocumentHeaderBuffer: Record KVSKBADocumentHeaderBuffer temporary; var ShipmentMethod: Record "Shipment Method"; var DocumentHeader: Record "Purchase Header"; var MasterDoc: Codeunit KVSKBAMasterDoc);
//     begin
//     end;

//     [IntegrationEvent(false, false)]
//     local procedure OnBeforeAddPaymentTerms(var DocumentHeaderBuffer: Record KVSKBADocumentHeaderBuffer temporary; var PaymentTerms: Record "Payment Terms"; var isHandled: Boolean; var DocumentHeader: Record "Purchase Header"; var MasterDoc: Codeunit KVSKBAMasterDoc);
//     begin
//     end;

//     [IntegrationEvent(false, false)]
//     local procedure OnAfterAddPaymentTerms(var DocumentHeaderBuffer: Record KVSKBADocumentHeaderBuffer temporary; var PaymentTerms: Record "Payment Terms"; var DocumentHeader: Record "Purchase Header"; var MasterDoc: Codeunit KVSKBAMasterDoc);
//     begin
//     end;

//     [IntegrationEvent(false, false)]
// #pragma warning disable AL0432
//     local procedure OnCasePrintVatSpecificationOnCaseElse(PrintVatSpecification: Enum KVSKBAPrintVatSpecification; var TempVATAmountLine: Record "VAT Amount Line" temporary; var SkipVATSpecVerification: Boolean)
// #pragma warning restore AL0432
//     begin
//     end;

//     [IntegrationEvent(false, false)]
// #pragma warning disable AL0432
//     local procedure OnPreDataItemVATSpec(var KVSKBADocumentHeaderBuffer: Record KVSKBADocumentHeaderBuffer temporary; var DocumentHeader: Record "Purchase Header"; var TempVATAmountLine: Record "VAT Amount Line" temporary; var SkipVATSpecVerification: Boolean; var IsHandled: Boolean; var KVSKBAMasterDoc: Codeunit KVSKBAMasterDoc);
// #pragma warning restore AL0432
//     begin
//     end;

//     [IntegrationEvent(false, false)]
// #pragma warning disable AL0432
//     local procedure OnPreDataItemVATSpecLCY(var KVSKBADocumentHeaderBuffer: Record KVSKBADocumentHeaderBuffer temporary; var DocumentHeader: Record "Purchase Header"; var TempVATAmountLine: Record "VAT Amount Line" temporary; var SkipVATSpecVerification: Boolean; var isHandled: Boolean; var KVSKBAMasterDoc: Codeunit KVSKBAMasterDoc);
// #pragma warning restore AL0432
//     begin
//     end;

//     // Item Tracking

//     // CopyLoop

//     [IntegrationEvent(false, false)]
//     local procedure OnAfterGetRecordCopyLoop(var DocumentHeaderBuffer: Record KVSKBADocumentHeaderBuffer temporary; var DocumentHeader: Record "Purchase Header"; var MasterDoc: Codeunit KVSKBAMasterDoc)
//     begin
//     end;

//     [IntegrationEvent(false, false)]
//     local procedure OnAfterGetRecordCopyLoop2(var DocumentHeaderBuffer: Record KVSKBADocumentHeaderBuffer temporary; var DocumentHeader: Record "Purchase Header"; var MasterDoc: Codeunit KVSKBAMasterDoc; CopyLoopNumber: Integer)
//     begin
//     end;

//     [IntegrationEvent(false, false)]
//     local procedure OnBeforeSetLanguageFormatAddress(DocHeader: Record "Purchase Header"; var IsHandled: Boolean)
//     begin
//     end;

//     [IntegrationEvent(false, false)]
//     local procedure OnBeforeResetLanguageFormatAddress(DocHeader: Record "Purchase Header"; var GlobalIsHandled: Boolean)
//     begin
//     end;

//     [IntegrationEvent(false, false)]
// #pragma warning disable AL0432
//     local procedure OnAfterTransferTotalAmount(var TempDocumentHeaderBuffer: Record KVSKBADocumentHeaderBuffer temporary; var TempVATAmountLine: Record "VAT Amount Line" temporary)
// #pragma warning restore AL0432
//     begin
//     end;
// }