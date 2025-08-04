// table 5048790 KVSKBADocumentDataItemBuffer
// {
//     Caption = 'Document DataItem Buffer';
//     DataClassification = SystemMetadata;

//     fields
//     {
//         field(1; "Doc Scope"; Enum KVSKBADocumentScope)
//         {
//             Caption = 'Doc Scope';
//             DataClassification = SystemMetadata;
//         }
//         field(2; "Doc Type"; Enum KVSKBADocumentType)
//         {
//             Caption = 'Doc Type';
//             DataClassification = SystemMetadata;
//         }
//         field(3; "No."; Code[20])
//         {
//             Caption = 'No.';
//             DataClassification = SystemMetadata;
//         }
//         field(4; "Doc. No. Occurrence"; Integer)
//         {
//             Caption = 'Doc. No. Occurrence';
//             DataClassification = SystemMetadata;
//         }
//         field(5; "Version No."; Integer)
//         {
//             Caption = 'Version No.';
//             DataClassification = SystemMetadata;
//         }
//         field(6; "Document Order No."; Integer)
//         {
//             Caption = 'Document Sequence No.';
//             DataClassification = SystemMetadata;
//         }
//         field(7; OutputNo; Integer)
//         {
//             Caption = 'Copy No.';
//             DataClassification = SystemMetadata;
//         }
//         field(8; "Entry No."; Integer)
//         {
//             Caption = 'Entry No.';
//             DataClassification = SystemMetadata;
//         }
//         field(11; "DataItem Type"; Enum KVSKBADocumentDataItemType)
//         {
//             Caption = 'DataItem Type';
//             DataClassification = SystemMetadata;
//         }
//         field(12; "Table Type"; Enum KVSKBADocumentTableType)
//         {
//             Caption = 'Table Type';
//             DataClassification = SystemMetadata;
//         }
//         field(13; "Line No."; Integer)
//         {
//             Caption = 'Line No.';
//             DataClassification = SystemMetadata;
//         }
//         field(14; "Detail Line No."; Integer)
//         {
//             Caption = 'Detail Line No.';
//             DataClassification = SystemMetadata;
//         }
//         field(15; "Line Type"; Enum KVSKBADocumentLineType)
//         {
//             Caption = 'Line Type';
//             DataClassification = SystemMetadata;
//         }
//         field(16; "Sort Trigger 1"; Text[50])
//         {
//             Caption = 'Sort Trigger 1';
//             DataClassification = SystemMetadata;
//         }
//         field(17; "Sort Trigger 2"; Text[50])
//         {
//             Caption = 'Sort Trigger 2';
//             DataClassification = SystemMetadata;
//         }
//         field(18; "Sort Trigger 3"; Text[50])
//         {
//             Caption = 'Sort Trigger 3';
//             DataClassification = SystemMetadata;
//         }
//         field(19; "Decimal 1"; Decimal)
//         {
//             Caption = 'Decimal 1';
//             DataClassification = SystemMetadata;
//         }
//         field(20; "Decimal 2"; Decimal)
//         {
//             Caption = 'Decimal 2';
//             DataClassification = SystemMetadata;
//         }
//         field(21; "Carry Amount"; Decimal)
//         {
//             Caption = 'Amt. Carried Over';
//             DataClassification = SystemMetadata;
//         }
//         field(22; "Page Break Trigger"; Integer)
//         {
//             Caption = 'Page Break Trigger';
//             DataClassification = SystemMetadata;
//         }
//         field(23; "Line Block Trigger"; Integer)
//         {
//             Caption = 'Line Block Trigger';
//             DataClassification = SystemMetadata;
//         }
//         field(24; "Line Format String"; Text[250])
//         {
//             Caption = 'Line Format';
//             DataClassification = SystemMetadata;
//         }
//         field(31; "Line Fields"; Blob)
//         {
//             Caption = 'Line Fields';
//             DataClassification = SystemMetadata;
//         }
//         field(32; "Formatted Text"; Blob)
//         {
//             Caption = 'Formatted Text';
//             DataClassification = SystemMetadata;
//         }
//         field(33; "Picture 1"; Blob)
//         {
//             Caption = 'Image 1';
//             DataClassification = SystemMetadata;
//             Subtype = Bitmap;
//         }
//         field(34; "Picture 2"; Blob)
//         {
//             Caption = 'Image 2';
//             DataClassification = SystemMetadata;
//             Subtype = Bitmap;
//         }
//         field(35; "Picture 3"; Blob)
//         {
//             Caption = 'Image 3';
//             DataClassification = SystemMetadata;
//             Subtype = Bitmap;
//         }
//     }

//     keys
//     {
//         key(Key1; "Doc Scope", "Doc Type", "No.", "Doc. No. Occurrence", "Version No.", "Document Order No.", OutputNo, "Entry No.")
//         {
//         }
//         key(Key2; "Entry No.")
//         {
//         }
//     }

//     var
//         TempDocHeaderBuffer: Record KVSKBADocumentHeaderBuffer temporary;
//         DocTextTranslation: Record KVSKBADocumentTextTranslation;
//         FieldDataList: Codeunit KVSKBAMasterDocFieldData;
//         CopyLoopNo: Integer;

//     procedure InitByHeader(var GlobalData: Codeunit KVSKBAMasterDocGlobalData; var tmpDocHeader: Record KVSKBADocumentHeaderBuffer temporary)
//     begin
//         // Initialize ItemBuffer by DocHeader
//         Init();
//         "Doc Scope" := tmpDocHeader."Doc Scope";
//         "Doc Type" := tmpDocHeader."Doc Type";
//         "No." := tmpDocHeader."No.";
//         "Doc. No. Occurrence" := tmpDocHeader."Doc. No. Occurrence";
//         "Version No." := tmpDocHeader."Version No.";
//         "Document Order No." := tmpDocHeader."Entry No.";

//         OutputNo := 0;
//     end;

//     procedure AddCustomFields(var CustomFieldsDataList: Codeunit KVSKBAMasterDocFieldData)
//     begin
//         // Add custom fields values to local FieldsDataList
//         CustomFieldsDataList.AddToFieldDataDict(FieldDataList);
//     end;

//     procedure InsertDocHeader(var GlobalData: Codeunit KVSKBAMasterDocGlobalData; var tmpDocHeader: Record KVSKBADocumentHeaderBuffer temporary)
//     var
//         IsHandled: Boolean;
//     begin
//         // Insert DataItem entry for DocHeader record
//         InitByHeader(GlobalData, tmpDocHeader);
//         "Entry No." := GlobalData.GetNextDataItemEntryNo();
//         "DataItem Type" := "DataItem Type"::DocHeader;

//         DocTextTranslation.GetLanguage(tmpDocHeader."Language Code");

//         IsHandled := false;
//         OnBeforeTransferPictures(DocTextTranslation, tmpDocHeader, IsHandled);
//         if IsHandled then
//             exit;

//         // Pictures from DocHeader are used primary
//         if tmpDocHeader."Picture 1".HasValue then
//             "Picture 1" := tmpDocHeader."Picture 1"
//         else
//             if DocTextTranslation."Picture 1".HasValue then
//                 "Picture 1" := DocTextTranslation."Picture 1";

//         if tmpDocHeader."Picture 2".HasValue then
//             "Picture 2" := tmpDocHeader."Picture 2"
//         else
//             if DocTextTranslation."Picture 2".HasValue then
//                 "Picture 2" := DocTextTranslation."Picture 2";

//         if tmpDocHeader."Picture 3".HasValue then
//             "Picture 3" := tmpDocHeader."Picture 3"
//         else
//             if DocTextTranslation."Picture 3".HasValue then
//                 "Picture 3" := DocTextTranslation."Picture 3";

//         SetLineFields(tmpDocHeader.GetFieldDataText());
//         GlobalData.InitDocumentLineValues();

//         Insert();
//     end;

//     procedure UpdateDocHeader(var GlobalData: Codeunit KVSKBAMasterDocGlobalData; var tmpDocHeader: Record KVSKBADocumentHeaderBuffer temporary; var CustomFieldsDataList: Codeunit KVSKBAMasterDocFieldData)
//     begin
//         // Update DataItem entry for DocHeader record
//         Reset();
//         SetRange("Doc Scope", tmpDocHeader."Doc Scope");
//         SetRange("Doc Type", tmpDocHeader."Doc Type");
//         SetRange("No.", tmpDocHeader."No.");
//         SetRange("Doc. No. Occurrence", tmpDocHeader."Doc. No. Occurrence");
//         SetRange("Version No.", tmpDocHeader."Version No.");
//         SetRange("DataItem Type", "DataItem Type"::DocHeader);
//         if FindSet() then begin
//             tmpDocHeader.BuildFieldDataList();
//             tmpDocHeader.AddCustomFields(CustomFieldsDataList);
//             SetLineFields(tmpDocHeader.GetFieldDataText());
//             Modify();
//         end else
//             InsertDocHeader(GlobalData, tmpDocHeader);
//     end;

//     procedure InsertDocHeading(var GlobalData: Codeunit KVSKBAMasterDocGlobalData; var tmpDocHeader: Record KVSKBADocumentHeaderBuffer temporary; var tmpDocHeading: Record KVSKBADocumentHeadingBuffer temporary)
//     begin
//         // Insert new HeadingLine
//         // if EntryNo is provided, use it (to insert additional lines between default lines); otherwise get next one
//         InitByHeader(GlobalData, tmpDocHeader);
//         if tmpDocHeading."Entry No." = 0 then
//             "Entry No." := GlobalData.GetNextDataItemEntryNo()
//         else
//             "Entry No." := tmpDocHeading."Entry No.";

//         "DataItem Type" := "DataItem Type"::DocHeading;
//         "Table Type" := tmpDocHeading.GetTableType();
//         "Line Type" := tmpDocHeading.GetLineType();

//         SetLineFields(tmpDocHeading.GetFieldData());

//         Insert();
//     end;

//     procedure InsertDocLine(var GlobalData: Codeunit KVSKBAMasterDocGlobalData; var tmpDocHeader: Record KVSKBADocumentHeaderBuffer temporary; var tmpDocLine: Record KVSKBADocumentLineBuffer temporary)
//     begin
//         // Insert new DocumentLine
//         InitByHeader(GlobalData, tmpDocHeader);
//         "Entry No." := GlobalData.GetNextDataItemEntryNo();

//         "DataItem Type" := "DataItem Type"::DocLine;
//         "Table Type" := tmpDocLine."Table Type";
//         "Line Type" := tmpDocLine."Line Type";

//         "Line No." := tmpDocLine."Line No.";
//         "Detail Line No." := tmpDocLine."Detail Line No.";
//         "Sort Trigger 1" := tmpDocLine."Sort Trigger 1";
//         "Sort Trigger 2" := tmpDocLine."Sort Trigger 2";
//         "Sort Trigger 3" := tmpDocLine."Sort Trigger 3";
//         "Line Format String" := tmpDocLine."Line Format String";
//         "Page Break Trigger" := GlobalData.GetNewPageTrigger();
//         "Line Block Trigger" := GlobalData.GetNewLineBlockTrigger();
//         "Carry Amount" := tmpDocLine."Carry Amount";
//         "Decimal 1" := tmpDocLine."Decimal 1";
//         "Decimal 2" := tmpDocLine."Decimal 2";

//         SetLineFields(tmpDocLine.GetFieldDataText());

//         Insert();
//     end;

//     procedure InsertDocTotalLine(var GlobalData: Codeunit KVSKBAMasterDocGlobalData; var tmpDocHeader: Record KVSKBADocumentHeaderBuffer temporary; var tmpDocTotal: Record KVSKBADocumentTotalBuffer temporary)
//     begin
//         // Insert new TotalLine
//         InitByHeader(GlobalData, tmpDocHeader);
//         "Entry No." := GlobalData.GetNextDataItemEntryNo();

//         "DataItem Type" := "DataItem Type"::DocTotal;
//         "Table Type" := tmpDocTotal.GetTableType();
//         "Line Type" := tmpDocTotal.GetLineType();

//         SetBlobText(tmpDocTotal.GetBlobText());
//         tmpDocTotal.BuildFieldDataList(tmpDocHeader);
//         SetLineFields(tmpDocTotal.GetFieldDataText());

//         Insert();
//     end;

//     procedure InsertDocVATInfoLine(var GlobalData: Codeunit KVSKBAMasterDocGlobalData; var tmpDocHeader: Record KVSKBADocumentHeaderBuffer temporary; var tmpDocTotal: Record KVSKBADocumentVATInfoBuffer temporary)
//     begin
//         // Insert new VATInfoLine
//         InitByHeader(GlobalData, tmpDocHeader);
//         "Entry No." := GlobalData.GetNextDataItemEntryNo();

//         "DataItem Type" := "DataItem Type"::DocTotal;
//         "Table Type" := tmpDocTotal.GetTableType();
//         "Line Type" := tmpDocTotal.GetLineType();

//         tmpDocTotal.BuildFieldDataList(tmpDocHeader);
//         SetLineFields(tmpDocTotal.GetFieldDataText());

//         Insert();
//     end;

//     procedure GetLineFields(): Text
//     var
//         InStreamLoc: InStream;
//         ReturnText: Text;
//     begin
//         // Retrieve LineFields text from blob
//         ReturnText := '';
//         //CalcFields("Line Fields"); // this deletes the value
//         if "Line Fields".HasValue() then begin
//             "Line Fields".CreateInStream(InStreamLoc, TextEncoding::UTF8);
//             InStreamLoc.Read(ReturnText);
//             if "DataItem Type" = "DataItem Type"::DocHeader then
//                 UpdateHeaderLineFieldsForCopy(ReturnText);
//         end;
//         exit(ReturnText);
//     end;

//     procedure SetLineFields(WriteText: Text)
//     var
//         OutStreamLoc: OutStream;
//     begin
//         // Save LineFields text to blob
//         Clear("Line Fields");
//         "Line Fields".CreateOutStream(OutStreamLoc, TextEncoding::UTF8);
//         OutStreamLoc.Write(WriteText);
//     end;

//     procedure GetBlobText() ReturnText: Text
//     var
//         InStreamLoc: InStream;
//     begin
//         // Retrieve formatted text blob content as text
//         //CalcFields("Formatted Text"); // this deletes the value
//         if "Formatted Text".HasValue() then begin
//             "Formatted Text".CreateInStream(InStreamLoc, TextEncoding::UTF8);
//             InStreamLoc.Read(ReturnText);
//         end;
//     end;

//     procedure SetBlobText(WriteText: Text)
//     var
//         OutStreamLoc: OutStream;
//     begin
//         // Write formatted text to formatted text blob
//         Clear("Formatted Text");
//         "Formatted Text".CreateOutStream(OutStreamLoc, TextEncoding::UTF8);
//         OutStreamLoc.Write(WriteText);
//     end;

//     procedure SetDocTextTranslation(var InDocTextTranslation: Record KVSKBADocumentTextTranslation)
//     begin
//         DocTextTranslation := InDocTextTranslation;
//     end;

//     procedure GetDocTextTranslation(var OutDocTextTranslation: Record KVSKBADocumentTextTranslation)
//     begin
//         OutDocTextTranslation := DocTextTranslation;
//     end;

//     procedure SetPicture1FromBlob(TempBlob: Codeunit "Temp Blob")
//     var
//         RecordRef: RecordRef;
//     begin
//         // Set picture 1 value by temp blob
//         RecordRef.GetTable(Rec);
//         TempBlob.ToRecordRef(RecordRef, FieldNo("Picture 1"));
//         RecordRef.SetTable(Rec);
//     end;

//     procedure SetPicture2FromBlob(TempBlob: Codeunit "Temp Blob")
//     var
//         RecordRef: RecordRef;
//     begin
//         // Set picture 2 value by temp blob
//         RecordRef.GetTable(Rec);
//         TempBlob.ToRecordRef(RecordRef, FieldNo("Picture 2"));
//         RecordRef.SetTable(Rec);
//     end;

//     procedure SetPicture3FromBlob(TempBlob: Codeunit "Temp Blob")
//     var
//         RecordRef: RecordRef;
//     begin
//         // Set picture 3 value by temp blob
//         RecordRef.GetTable(Rec);
//         TempBlob.ToRecordRef(RecordRef, FieldNo("Picture 3"));
//         RecordRef.SetTable(Rec);
//     end;

//     procedure SetCopyLoopNo(LoopNo: Integer)
//     begin
//         // Update CopyLoop No
//         CopyLoopNo := LoopNo;
//     end;

//     procedure UpdateHeaderLineFieldsForCopy(var LineFields: Text)
//     begin
//         // Update line fields depending on copy no.
//         if CopyLoopNo = 1 then
//             FieldDataList.UpdateFieldTextValue(LineFields, TempDocHeaderBuffer.GetLayout_CopyTextToken(), '');
//     end;

//     [IntegrationEvent(false, false)]
//     local procedure OnBeforeTransferPictures(var KVSKBADocumentTextTranslation: Record KVSKBADocumentTextTranslation; var TempKVSKBADocumentHeaderBuffer: Record KVSKBADocumentHeaderBuffer temporary; var IsHandled: Boolean)
//     begin
//     end;
// }