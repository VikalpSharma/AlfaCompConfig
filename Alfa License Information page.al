page 70140957 "Alfa License Card"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Alfa License";
    Caption = 'Alfa License';
    Editable = false;

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field("Product ID"; "Product ID")
                {
                    ApplicationArea = All;
                    Caption = 'Product Id';
                    ToolTip = 'Id of the product app.';

                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    Caption = 'Product Description';
                    ToolTip = 'Product Description';
                }
                field("License Key"; "License Key")
                {
                    ApplicationArea = All;
                    Caption = 'License Key';
                    ToolTip = 'Lisense key for the product app';
                }
            }
        }
    }
}