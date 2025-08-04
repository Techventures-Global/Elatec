tableextension 50500 PurchLineable extends "Purchase Line"
{
    fields
    {
        field(50500; TVS_LineNo; Integer)
        {
        }
    }
    // keys
    // {
    //     key(key_2; TVS_LineNo)
    //     { }
    // }
    trigger OnAfterInsert()
    begin
        Rec.TVS_LineNo := Rec."Line No." / 10000;
        Rec.Modify();
    end;
}



