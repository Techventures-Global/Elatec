reportextension 50503 SaleCreditMemoExtension extends 5048925
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
            column(Currency_Code; "Currency Code") { }
        }
        addlast(DocHeader)
        {
            dataitem(DocumentLine; "Sales Cr.Memo Line")
            {
                DataItemLinkReference = DocHeader;
                DataItemLink = "Document No." = field("No.");
                DataItemTableView = sorting("Document No.", "Line No.");
                column(Unit_of_Measure_Code; "Unit of Measure Code")
                {
                }
                column(Amount_Including_VAT; "Amount Including VAT") { }
                //column(TVS_LineNo; TVS_LineNo) { }
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


    rendering
    {
        layout("Sales Credit-Memo")
        {
            Type = RDLC;
            LayoutFile = './Reports/Sales Credit Memo.rdlc';
        }
    }
    trigger OnPreReport()
    begin
        CompInfo.Get();
    end;

    var
        CompInfo: Record "Company Information";
        Rep: Report 1322;
        tab: Record 38;
        tabl: Record 39;
        LineNo1: Integer;
}
