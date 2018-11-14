page 70140924 "UAE VAT Setup Wizard"
{
    PageType = NavigatePage;
    SourceTable = "Company Information";
    Caption = 'UAE VAT Setup';
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(StandardBanner)
            {
                Editable = False;
                Visible = TopBannerVisible and (CurrentStep < 3);
            }

            group(FinishedBanner)
            {
                Editable = False;
                Visible = TopBannerVisible and (CurrentStep = 3);
            }

            group(Step1)
            {
                Visible = (CurrentStep = 1);

                group(Welcome)
                {
                    Caption = 'Welcome';
                    InstructionalText = 'Welcome to the VAT Setup wizard.';

                    group(MasterData)
                    {
                        Caption = 'This wizard will take you through the process of creating the following VAT specific masters required for UAE';

                        label(line1)
                        {
                            ApplicationArea = All;
                            Caption = '';
                        }
                        label(Bus)
                        {
                            ApplicationArea = All;
                            Caption = '1. VAT Business Posting Groups';
                        }
                        label(Prod)
                        {
                            ApplicationArea = All;
                            Caption = '2. VAT Product Posting Groups';
                        }
                        label(UAE)
                        {
                            ApplicationArea = All;
                            Caption = '3. VAT Groups';
                        }
                    }
                }
            }
            group(Step2)
            {
                Visible = CurrentStep = 2;
                Caption = 'VAT Business Posting Group';
                InstructionalText = 'The following VAT Business Posting Groups will be created:-';

                group(VATBUSGroup)
                {
                    Caption = 'Business Posting Groups';

                    label(VAT_DXB)
                    {
                        ApplicationArea = All;
                        Caption = '1. VAT_DXB';
                    }
                    label(VAT_SHJ)
                    {
                        ApplicationArea = All;
                        Caption = '2. VAT_SHJ';
                    }
                    label(VAT_FUJ)
                    {
                        ApplicationArea = All;
                        Caption = '3. VAT_FUJ';
                    }
                    label(VAT_AUH)
                    {
                        ApplicationArea = All;
                        Caption = '4. VAT_AUH';
                    }
                    label(VAT_AJM)
                    {
                        ApplicationArea = All;
                        Caption = '5. VAT_AJM';
                    }
                    label(VAT_RAK)
                    {
                        ApplicationArea = All;
                        Caption = '6. VAT_RAK';
                    }
                    label(VAT_UAQ)
                    {
                        ApplicationArea = All;
                        Caption = '7. VAT_UAQ';
                    }
                    label(VAT_GCC)
                    {
                        ApplicationArea = All;
                        Caption = '8. VAT_GCC';
                    }
                    label(VAT_OTHERS)
                    {
                        ApplicationArea = All;
                        Caption = '9. VAT_OTHERS';
                    }
                }
            }
            Group(Step3)
            {
                Visible = CurrentStep = 3;
                Caption = 'VAT Product Posting Group';
                InstructionalText = 'The following VAT Product Posting Groups will be created:-';

                group(VATPRODGroup)
                {
                    Caption = 'Product Posting Groups';

                    label(Zero)
                    {
                        ApplicationArea = All;
                        Caption = '1. VAT_0';
                    }
                    label(VAT_5G)
                    {
                        ApplicationArea = All;
                        Caption = '2. VAT_5G';
                    }
                    label(VAT_5S)
                    {
                        ApplicationArea = All;
                        Caption = '3. VAT_5S';
                    }
                    label(VAT_EX)
                    {
                        ApplicationArea = All;
                        Caption = '4. VAT_EX';
                    }
                }
            }

            group(Step4)
            {
                Visible = CurrentStep = 4;
                Caption = 'VAT Groups';
                InstructionalText = 'The following VAT Groups will be created:-';
                group(VATGroups)
                {
                    Caption = 'VAT Groups';
                    label(DXB)
                    {
                        ApplicationArea = All;
                        Caption = '1. DXB';
                    }
                    label(AUH)
                    {
                        ApplicationArea = All;
                        Caption = '2. AUH';
                    }
                    label(SHJ)
                    {
                        ApplicationArea = All;
                        Caption = '3. SHJ';
                    }
                    label(AJM)
                    {
                        ApplicationArea = All;
                        Caption = '4. AJM';
                    }
                    label(UAQ)
                    {
                        ApplicationArea = All;
                        Caption = '5. UAQ';
                    }
                    label(RAK)
                    {
                        ApplicationArea = All;
                        Caption = '6. RAK';
                    }
                    label(FUJ)
                    {
                        ApplicationArea = All;
                        Caption = '7. FUJ';
                    }
                }
            }
        }
    }


    actions
    {
        area(processing)
        {
            action(ActionBack)
            {
                ApplicationArea = All;
                Caption = 'Back';
                InFooterBar = true;
                Image = PreviousRecord;
                Enabled = ActionBackAllowed;

                trigger OnAction()
                begin
                    TakeStep(-1);
                end;
            }

            action(ActionNext)
            {
                ApplicationArea = All;
                Caption = 'Next';
                InFooterBar = true;
                Image = NextRecord;
                Enabled = ActionNextAllowed;

                trigger OnAction()
                begin
                    TakeStep(1);
                end;
            }

            action(ActionFinish)
            {
                ApplicationArea = All;
                Caption = 'Finish';
                InFooterBar = true;
                Image = Approve;
                Enabled = ActionFinishAllowed;

                trigger OnAction()
                begin
                    //update the records into the desired tables
                    IF VATBusPostGroup.Get('VAT_DXB') = false then begin
                        VATBusPostGroup.Init();
                        VATBusPostGroup.Code := 'VAT_DXB';
                        VATBusPostGroup.Description := 'VAT Group for Dubai';
                        VATBusPostGroup.Insert();
                    end;

                    IF VATBusPostGroup.Get('VAT_SHJ') = false then begin
                        VATBusPostGroup.Init();
                        VATBusPostGroup.Code := 'VAT_SHJ';
                        VATBusPostGroup.Description := 'VAT Group for Sharjah';
                        VATBusPostGroup.Insert();
                    end;

                    IF VATBusPostGroup.Get('VAT_FUJ') = false then begin
                        VATBusPostGroup.Init();
                        VATBusPostGroup.Code := 'VAT_FUJ';
                        VATBusPostGroup.Description := 'VAT Group for Fujairah';
                        VATBusPostGroup.Insert();
                    end;

                    IF VATBusPostGroup.Get('VAT_AUH') = false then begin
                        VATBusPostGroup.Init();
                        VATBusPostGroup.Code := 'VAT_AUH';
                        VATBusPostGroup.Description := 'VAT Group for Abu Dhabi';
                        VATBusPostGroup.Insert();
                    end;

                    IF VATBusPostGroup.Get('VAT_RAK') = false then begin
                        VATBusPostGroup.Init();
                        VATBusPostGroup.Code := 'VAT_RAK';
                        VATBusPostGroup.Description := 'VAT Group for Ras Al Khaimah';
                        VATBusPostGroup.Insert();
                    end;

                    IF VATBusPostGroup.Get('VAT_AJM') = false then begin
                        VATBusPostGroup.Init();
                        VATBusPostGroup.Code := 'VAT_AJM';
                        VATBusPostGroup.Description := 'VAT Group for Ajman';
                        VATBusPostGroup.Insert();
                    end;

                    IF VATBusPostGroup.Get('VAT_UAQ') = false then begin
                        VATBusPostGroup.Init();
                        VATBusPostGroup.Code := 'VAT_UAQ';
                        VATBusPostGroup.Description := 'VAT Group for Umm Al Quwain';
                        VATBusPostGroup.Insert();
                    end;

                    IF VATBusPostGroup.Get('VAT_KSA') = false then begin
                        VATBusPostGroup.Init();
                        VATBusPostGroup.Code := 'VAT_KSA';
                        VATBusPostGroup.Description := 'VAT Group for SAUHi Arabia';
                        VATBusPostGroup.Insert();
                    end;

                    IF VATBusPostGroup.Get('VAT_OTHERS') = false then begin
                        VATBusPostGroup.Init();
                        VATBusPostGroup.Code := 'VAT_OTHERS';
                        VATBusPostGroup.Description := 'VAT Group for others';
                        VATBusPostGroup.Insert();
                    end;



                    If VATProdPostGroup.Get('VAT_0') = false then begin
                        VATProdPostGroup.init;
                        VATProdPostGroup.Code := 'VAT_0';
                        VATProdPostGroup.Description := 'VAT 0%';
                        VATProdPostGroup.Insert();
                    end;

                    if VATProdPostGroup.Get('VAT_5G') = false then begin
                        VATProdPostGroup.init;
                        VATProdPostGroup.Code := 'VAT_5G';
                        VATProdPostGroup.Description := 'VAT 5% Goods';
                        VATProdPostGroup.Insert();
                    end;

                    if VATProdPostGroup.Get('VAT_5S') = false then begin
                        VATProdPostGroup.init;
                        VATProdPostGroup.Code := 'VAT_5S';
                        VATProdPostGroup.Description := 'VAT 5% Services';
                        VATProdPostGroup.Insert();
                    end;

                    if VATProdPostGroup.Get('VAT_EX') = false then begin
                        VATProdPostGroup.init;
                        VATProdPostGroup.Code := 'VAT_EX';
                        VATProdPostGroup.Description := 'VAT Exempted';
                        VATProdPostGroup.Insert();
                    end;



                    /* if VATGroupCodes.Get('AJM') = false then
                     begin
                         VATGroupCodes.init;
                         VATGroupCodes."Group Code" := 'AJM';
                         VATGroupCodes.Description := 'Ajman';
                         VATGroupCodes.insert();
                     end;
                     if VATGroupCodes.Get('AUH') = false then
                     begin
                         VATGroupCodes.init;
                         VATGroupCodes."Group Code" := 'AUH';
                         VATGroupCodes.Description := 'Abu Dhabi';
                         VATGroupCodes.insert();
                     end;
                     if VATGroupCodes.Get('DXB') = false then
                     begin
                         VATGroupCodes.init;
                         VATGroupCodes."Group Code" := 'DXB';
                         VATGroupCodes.Description := 'Dubai';
                         VATGroupCodes.insert();
                     end;
                     if VATGroupCodes.Get('FUJ') = false  then
                     begin
                         VATGroupCodes.init;
                         VATGroupCodes."Group Code" := 'FUJ';
                         VATGroupCodes.Description := 'Fujairah';
                         VATGroupCodes.insert();
                     end;
                     if VATGroupCodes.Get('RAK') = false then
                     begin
                         VATGroupCodes.init;
                         VATGroupCodes."Group Code" := 'RAK';
                         VATGroupCodes.Description := 'Ras Al Khaimah';
                         VATGroupCodes.insert();
                     end;
                     if VATGroupCodes.Get('SHJ') = false then
                     begin
                         VATGroupCodes.init;
                         VATGroupCodes."Group Code" := 'SHJ';
                         VATGroupCodes.Description := 'Sharjah';
                         VATGroupCodes.insert();
                     end;
                     if VATGroupCodes.Get('UAQ') = false then
                     begin
                         VATGroupCodes.init;
                         VATGroupCodes."Group Code" := 'UAQ';
                         VATGroupCodes.Description := 'Um Al Quwain';
                         VATGroupCodes.insert();
                     end;
                     */
                    CurrPage.Close();
                end;
            }

        }
    }

    trigger OnOpenPage()
    begin
        CurrentStep := 1;
        SetControls();
    end;

    trigger OnInit()
    begin
        LoadTopBanners();
    end;

    local procedure LoadTopBanners()
    begin
        if (MediaRepositoryStandard.Get('AssistedSetup-NoText-400px.png', Format(CurrentClientType)) and
        MediaRepositoryDone.Get('AssistedSetupDone-NoText-400px.png', Format(CurrentClientType)))
        then
            if (MediaResourcesStandard.Get(MediaRepositoryStandard."Media Resources Ref") and
                MediaResourcesDone.Get(MediaRepositoryDone."Media Resources Ref"))
            then
                TopBannerVisible := MediaResourcesDone."Media Reference".HasValue();
    end;

    local procedure SetControls()
    begin
        ActionBackAllowed := CurrentStep > 1;
        ActionNextAllowed := CurrentStep < 4;
        ActionFinishAllowed := CurrentStep = 4;
    end;

    local procedure TakeStep(Step: Integer)
    begin
        CurrentStep += Step;
        SetControls();
    end;

    var
        CurrentStep: Integer;
        ActionBackAllowed: Boolean;
        ActionNextAllowed: Boolean;
        ActionFinishAllowed: Boolean;
        MediaRepositoryStandard: Record "Media Repository";
        MediaRepositoryDone: Record "Media Repository";
        MediaResourcesStandard: Record "Media Resources";
        MediaResourcesDone: Record "Media Resources";
        TopBannerVisible: Boolean;
        VATBusPostGroup: Record "VAT Business Posting Group";
        VATProdPostGroup: Record "VAT Product Posting Group";
        //VATGroupCodes : Record "UAE VAT Group Code";
}