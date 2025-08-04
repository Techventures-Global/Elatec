reportextension 50502 SaleInvoiceExtension extends 5048924
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
            dataitem(DocumentLine; "Sales Invoice Line")
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
            }

        }
    }


    rendering
    {
        layout("Sales - Invoice")
        {
            Type = RDLC;
            LayoutFile = './Reports/SaleInvoice.rdlc';
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
