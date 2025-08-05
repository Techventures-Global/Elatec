reportextension 50500 PurchaseOrderExtension extends 5048933
{
    dataset
    {
        add(DocHeader)
        {
            column(VAT_Registration_No_1; CompInfo."VAT Registration No.")
            {

            }
            column(VAT_Registration_No_; "VAT Registration No.")
            { }
        }
        addlast(DocHeader)
        {
            dataitem(DocumentLine; "Purchase Line")
            {
                DataItemLinkReference = DocHeader;
                DataItemLink = "Document No." = field("No.");

                //DataItemTableView = sorting("Document Type", "Document No.", "Line No.");
                column(Unit_of_Measure_Code; "Unit of Measure Code")
                {
                }
                column(Amount_Including_VAT; "Amount Including VAT") { }
                column(TVS_LineNo; TVS_LineNo) { }
                column(DocumentNo; "Document No.") { }
                column(LineNo; LineNo1) { }
                column(VAT__; "VAT %") { }

                trigger OnAfterGetRecord()
                begin
                    LineNo1 := DocumentLine."Line No." / 10000;
                end;

                trigger OnPreDataItem()

                begin
                    DocumentLine.SetRange("Document No.", DocHeader."No.");
                end;
            }


        }
    }
    requestpage
    {
        trigger OnOpenPage()
        begin
            DocumentLine.SetFilter("Document No.", '');
        end;
    }

    rendering
    {
        layout("Purchase - Order")
        {
            Type = RDLC;
            LayoutFile = './Reports/KVSKFWMasterDocument.rdlc';
        }
    }

    trigger OnPreReport()
    begin
        CompInfo.Get();
    end;

    var
        CompInfo: Record "Company Information";
        LineNo1: Integer;
        Rep: Report 1322;
        tab: Record 38;
        tabl: Record 39;
        PurchaseLine: Record "Purchase Line";
        UOMC: Code[10];
        PurchLine: Page "Purchase Lines";
        GlobalMasterDoc_: Codeunit KVSKBAMasterDoc;
        TempDocDataItemBuffer_: Record KVSKBADocumentDataItemBuffer temporary;
        TempDocLineBuffer_: Record KVSKBADocumentLineBuffer temporary;
        KVSKBAReqPageAdvOptionValues: Record "KVSKBAReqPageAdvOptionValues";
}