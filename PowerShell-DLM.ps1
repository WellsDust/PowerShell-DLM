# Load external assemblies
[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void][Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void][Reflection.Assembly]::LoadWithPartialName("System.Management.Automation.PSMethod")
Add-Type -AssemblyName PresentationCore,PresentationFramework

function MsgBox{
    param(
        [string]$msg,[string]$title
    )
    [System.Windows.MessageBox]::Show($msg,$title)
}

function Point{
    param ([int32]$x, [int32]$y)
    return (New-Object System.Drawing.Point($x,$y))
}
function Size{
    param([int32]$x, [int32]$y)
    return (New-Object System.Drawing.Size($x,$y))
}

function GetMousePos{
    return [System.Windows.Forms.Cursor]::Position
}
#########################################################
############################  Global Variables
$global:MDPos
$global:MDSize
$global:MDLoc
$global:Resizing
$global:ResizeTarg
$global:PropOwner
$global:ObjSelect = New-Object System.Windows.Forms.Label
$global:ObjSelect.BackColor = [System.Drawing.Color]::Transparent
$global:ObjSelect.ForeColor = [System.Drawing.Color]::Transparent

function FormBorder_MouseHover(){
    $MousePos_X = [System.Windows.Forms.Cursor]::Position.X
    $MousePos_Y = [System.Windows.Forms.Cursor]::Position.Y
    $LeftEdge = $this.Location.X + $DLM.Location.X
    $RightEdge = $this.Location.X + $DLM.Location.X + $this.Size.Width
    $TopEdge = $this.Location.Y + $DLM.Location.Y
    $BottomEdge = $this.Location.Y + $DLM.Location.Y + $this.Size.Height
    $offset = 5
    if($this.Name -eq "FormBorder"){$offset=5}
    if($MousePos_X -ge ($RightEdge-$offset)){
       # Write-Host $TopEdge $MousePos_Y
        if($MousePos_Y -le ($TopEdge - $offset)){
            #Write-Host "Top Right"
            $this.Cursor = [System.Windows.Forms.Cursors]::SizeNWSE
        }elseif($MousePos_Y -ge ($BottomEdge - $offset)){
            $this.Cursor = [System.Windows.Forms.Cursors]::SizeNWSE
        }else {
            $this.Cursor = [System.Windows.Forms.Cursors]::SizeWE
        }
    }elseif($MousePos_Y -ge ($BottomEdge+5+$offset)){
        $this.Cursor = [System.Windows.Forms.Cursors]::SizeNS
    }else{
        $this.Cursor = [System.Windows.Forms.Cursors]::Default
    }
}

function FormBorder_MouseDown{
    $MousePos_X = [System.Windows.Forms.Cursor]::Position.X
    $MousePos_Y = [System.Windows.Forms.Cursor]::Position.Y
    $LeftEdge = $this.Location.X + $DLM.Location.X 
    $RightEdge = $this.Location.X + $DLM.Location.X + $this.Size.Width
    $TopEdge = $this.Location.Y + $DLM.Location.Y 
    $BottomEdge = $this.Location.Y + $DLM.Location.Y +  $this.Size.Height
    $offset = 0
    if($this.Name -eq "FormBorder"){$offset=5}
    $CanSize = $false
    if($MousePos_X -ge ($RightEdge-$offset)){
       # Write-Host $TopEdge $MousePos_Y
        if($MousePos_Y -le ($TopEdge - $offset)){
            $CanSize = $true
        }elseif($MousePos_Y -ge ($BottomEdge - $offset)){
            $CanSize = $true
        }else {
            $CanSize = $true
        }
    }elseif($MousePos_Y -ge ($BottomEdge+$offset)){
        $CanSize = $true
    }

    if($CanSize){
        #Write-Host "Start Size"
        $global:MDPos = [System.Windows.Forms.Cursor]::Position
        $global:ResizeTarg = $this
        $global:Resizing = $true
        $global:MDSize = $this.Size
        #Write-Host $this.Name
    }else{
        $global:Moving =$true
        $global:MoveTarg = $this
        $global:MDLoc = $this.Location
        $global:MDPos = [System.Windows.Forms.Cursor]::Position
    }
}

function FormBorder_MouseUp{
    #Write-Host "End Size"
    $global:ResizeTarg.Cursor = [System.Windows.Forms.Cursors]::Default
    $this.Cursor = [System.Windows.Forms.Cursors]::Default
    $global:Resizing = $false
    $global:Moving = $false
}

function NewItem_MouseMove(){
    $parent = FindParentControl -child_form $this
    $MousePos_X = [System.Windows.Forms.Cursor]::Position.X
    $MousePos_Y = [System.Windows.Forms.Cursor]::Position.Y
    
    $LeftEdge = $this.Location.X + $DLM.Location.X + $FormPanel.Location.X
    $RightEdge = $LeftEdge + $this.Size.Width
    $TopEdge = $this.Location.Y + $DLM.Location.Y + $FormPanel.Location.Y + 25
    $BottomEdge = $TopEdge+ $this.Size.Height
    #$FormTitlebar.Text = ($MousePos_X.ToString() +"," +$MousePos_Y.ToString() + "|" + $BottomEdge.ToString())
    if($parent.Name -eq "TABCTRL_"){
        foreach($item in $FormPanel.Controls){
            if($item.Name -eq "TABCTRL_"){
                $TCtrl = $item.Controls[0]
                $TPage = $TCtrl.TabPages[$TCtrl.SelectedIndex]
                $truecontainer = $false
                
                foreach($ctrl in $TPage.Controls){
                    if($ctrl.Name -eq $this.Name){
                        $truecontainer = $true
                    }
                }
                if($truecontainer){
                    $LeftEdge += $item.Location.X
                    $RightEdge += $item.Location.X
                    $TopEdge += $item.Location.Y+20
                    $BottomEdge += $item.Location.Y+20
                }
            }
        }
    }elseif($parent.Name -ne "FormPanel" -and $parent.GetType().ToString() -in @("System.Windows.Forms.Panel","System.Windows.Forms.GroupBox")){
        $LeftEdge += $parent.Location.X
        $RightEdge += $parent.Location.X
        $TopEdge += $parent.Location.Y+20
        $BottomEdge += $parent.Location.Y+20
    }
    if($MousePos_X -ge ($RightEdge)){
       # Write-Host $TopEdge $MousePos_Y
        if($MousePos_Y -le ($TopEdge)){
            #Write-Host "Top Right"
            $this.Cursor = [System.Windows.Forms.Cursors]::SizeNWSE
        }elseif($MousePos_Y -ge ($BottomEdge)){
            $this.Cursor = [System.Windows.Forms.Cursors]::SizeNWSE
        }else {
            $this.Cursor = [System.Windows.Forms.Cursors]::SizeWE
        }
    }elseif($MousePos_Y -ge ($BottomEdge)){
        $this.Cursor = [System.Windows.Forms.Cursors]::SizeNS
    }else{
        $this.Cursor = [System.Windows.Forms.Cursors]::Default
    }
    

}

function NewItem_MouseDown{
    if($_.Button -eq [System.Windows.Forms.MouseButtons]::Left){
        $parent = FindParentControl -child_form $this
        $MousePos_X = [System.Windows.Forms.Cursor]::Position.X
        $MousePos_Y = [System.Windows.Forms.Cursor]::Position.Y
        $LeftEdge = $this.Location.X + $DLM.Location.X + $FormPanel.Location.X
        $RightEdge = $LeftEdge + $this.Size.Width
        $TopEdge = $this.Location.Y + $DLM.Location.Y + $FormPanel.Location.Y + 25
        $BottomEdge = $TopEdge+ $this.Size.Height
        Write-Host ("Top Edge: " + $TopEdge.ToString() + "`nMouse Y: "+$MousePos_Y)
        if($parent.Name -eq "TABCTRL_"){
            foreach($item in $FormPanel.Controls){
                if($item.Name -eq "TABCTRL_"){
                    $TCtrl = $item.Controls[0]
                    $TPage = $TCtrl.TabPages[$TCtrl.SelectedIndex]
                    $truecontainer = $false
                
                    foreach($ctrl in $TPage.Controls){
                        if($ctrl.Name -eq $this.Name){
                            $truecontainer = $true
                        }
                    }
                    if($truecontainer){
                        $LeftEdge += $item.Location.X
                        $RightEdge += $item.Location.X
                        $TopEdge += $item.Location.Y+20
                        $BottomEdge += $item.Location.Y+20
                    }
                }
            }
        }elseif($parent.Name -ne "FormPanel" -and $parent.GetType().ToString() -in @("System.Windows.Forms.Panel","System.Windows.Forms.GroupBox")){
            $LeftEdge += $parent.Location.X
            $RightEdge += $parent.Location.X
            $TopEdge += $parent.Location.Y+20
            $BottomEdge += $parent.Location.Y+20
        }
        $offset = 0
        $CanSize = $false
        if($MousePos_X -ge ($RightEdge)){
           # Write-Host $TopEdge $MousePos_Y
            if($MousePos_Y -le ($TopEdge)){
                $CanSize = $true
            }elseif($MousePos_Y -ge ($BottomEdge)){
                $CanSize = $true
            }else {
                $CanSize = $true
            }
        }elseif($MousePos_Y -ge ($BottomEdge)){
            $CanSize = $true
        }

        if($CanSize){
            Write-Host "Start Size"
            $global:MDPos = [System.Windows.Forms.Cursor]::Position
            $global:ResizeTarg = $this
            $global:Resizing = $true
            $global:MDSize = $this.Size
            #Write-Host $this.Name
        }else{
            $global:Moving =$true
            $global:MoveTarg = $this
            $global:MDLoc = $this.Location
            $global:MDPos = [System.Windows.Forms.Cursor]::Position
        }
    }
    #################### Populate "Properties" window ($FormProperties) ##################
    if($global:PropOwner -ne $this){
        foreach($item in $FormProperties.Controls){
            
            $item.Dispose()
        }
        $FormProperties.Controls.Clear()
        $NextY = 0
        Write-Host $this.Name
        if($this.Name -eq "TABCTRL_"){
            $global:PropOwner = $this.Controls[0]
        }else {$global:PropOwner = $this}
        #$parent = FindParentControl -child_form $global:PropOwner
        if($global:PropOwner){
            foreach($prop in $global:PropOwner.GetType().GetProperties()){
        
                $ePropName = $prop.Name
                if($ePropName -notin $UnsupportedVariables){
                    $ePropValue = $prop.GetValue($global:PropOwner)

                    $PropLabel = New-Object System.Windows.Forms.Label
                    $PropLabel.Location = Point 0 $NextY
                    $PropLabel.Size = Size 100 25
                    $PropLabel.Text = $ePropName
                    $PropLabel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
                    $PropType= $prop.ToString().Split(" ")[0]
                    #Write-Host ($prop.Name + ": "+$PropType)
                    if($PropType -eq "Boolean" ){
                        $PropValue = New-Object System.Windows.Forms.ComboBox
                        $PropValue.Items.AddRange(@("True","False"))
                    }
                    elseif($PropType -eq "System.String"){
                        $PropValue = New-Object System.Windows.Forms.TextBox
            
                    }elseif($PropType -eq "Int32"){
                        $PropValue = New-Object System.Windows.Forms.NumericUpDown
                        $PropValue.Maximum = 9999
            
                    }elseif($PropType -eq "System.Windows.Forms.BorderStyle"){
                        $PropValue = New-Object System.Windows.Forms.ComboBox
                        $PropValue.Items.AddRange(@("None","Fixed3D", "Fixed Single"))
            
            
                    }elseif ($PropType -eq "System.Drawing.Color"){
                        $PropValue = New-Object System.Windows.Forms.Button
                        #[System.Drawing.Color]::FromArgb(180,180,180)
                        $PropValue.BackColor = $ePropValue
                        $PropValue.ForeColor = $ePropValue
                        $PropValue.Add_Click({PropValue_ChangeColor})
                    }elseif ($PropType -eq "System.Drawing.Font"){
                        $PropValue = New-Object System.Windows.Forms.Button
                        #[System.Drawing.Color]::FromArgb(180,180,180)
                        $PropValue.Font = $ePropValue
                        $PropValue.Text = $ePropValue.FontFamily.Name
                        $PropValue.Add_Click({PropValue_ChangeFont})
                    }elseif($PropType -eq "System.Drawing.ContentAlignment"){
                        #[System.Drawing.ContentAlignment]::
                        $PropValue = New-Object System.Windows.Forms.ComboBox
                        $PropValue.Items.AddRange(@("TopLeft","TopCenter","TopRight","MiddleLeft","MiddleCenter","MiddleRight","BottomLeft","BottomCenter","BottomRight"))
                    }elseif($PropType -eq "System.Windows.Forms.Appearance"){
                        #[System.Windows.Forms.Appearance]::
                        $PropValue = New-Object System.Windows.Forms.ComboBox
                        $PropValue.Items.AddRange(@("Button","Normal"))
                    }elseif($PropType -eq "System.Windows.Forms.AnchorStyles"){
                        #[System.Windows.Forms.AnchorStyles]::
                        $PropValue = New-Object System.Windows.Forms.ComboBox
                        $PropValue.Items.AddRange(@("None", "Top","Top, Left", "Top, Left, Right","Top, Bottom, Left, Right", "Bottom", "Bottom, Left, Right","Bottom, Right","Left","Left, Right","Right"))
                    }elseif($PropType -eq "System.Windows.Forms.DockStyle"){
                        #[System.Windows.Forms.DockStyle]::
                        $PropValue = New-Object System.Windows.Forms.ComboBox
                        $PropValue.Items.AddRange(@("None","Fill", "Top", "Bottom", "Left","Right"))
                    }
                    else {
                        #Write-Host $PropType
                        $PropValue = New-Object System.Windows.Forms.TextBox
                        $ePropValue = $PropType
                    }
                    if($PropValue -ne $null){
                        if($PropType -ne "System.Drawing.Font"){$PropValue.Text = $ePropValue}
                        $PropValue.Name = $ePropName
                        $PropValue.Location = Point 100 $NextY
                        $PropValue.Size = Size 130 25
                        #$FormBorder.LostFocus
                        $PropValue.Add_LostFocus({PropValue_Change})
                        $PropValue.Add_Enter({PropValue_Change})
                        $PropValue.Add_TextChanged({PropValue_Change})
        
                        $FormProperties.Controls.AddRange(@($PropLabel,$PropValue))
                    }
                    $NextY = $NextY + 25
                }
            }
        }
        else{
            Write-Host "No PropOwner?"
        }
    }
}

$global:DoubleClick = $false
function NewItem_MouseUp{
    FormPanel_MouseClick
    if($global:DoubleClick){
        $global:Moving = $false
        $global:DoubleClick = $false
        
        Write-Host "Insert DoubleClick action..."
        if($this.Name -eq "TABCTRL_"){
            $item = $this.Controls[0]
            if($item -ne $null){
                $item.TabPages.Add("Tab Page ("+($item.TabPages.Count+1).ToString()+")")
                $global:Numbers++
                $item.TabPages[$item.TabPages.Count-1].Name = ("Tab Page "+$global:Numbers.ToString())
                $this.Text = "........................" + $this.Text
            }
        }else{
            View_Code
            $LastInd = $FormCode.Text.LastIndexOf('$'+$this.Name +".")
            $FormCode.SelectionStart = $LastInd
            $FormCode.SelectionLength = $this.Name.Length + 2
            if($FormCode.Text.Contains('$'+$this.Name +'.add_Click(') -eq $false){
                $GetLine = $FormCode.GetLineFromCharIndex($LastInd)
                $FormCode.SelectionStart = $FormCode.Text.IndexOf($FormCode.Lines[$GetLine])
                $FormCode.SelectedText = '$'+$this.Name +'.add_Click({$'+$this.Name+"_Click})" + [System.Environment]::NewLine + $FormCode.SelectedText
            }
            
        }
    }
    else {
        $global:DoubleClick = $true
        if($global:Resizing){
            Write-Host $global:ResizeTarg.ToString()
            $global:ResizeTarg.Cursor = [System.Windows.Forms.Cursors]::Default
        }
        $this.Cursor = [System.Windows.Forms.Cursors]::Default
        $global:Resizing = $false
        $global:Moving = $false
        if($this -in $FormPanel.Controls){
            foreach($item in $FormPanel.Controls){
                if($this -ne $item){
                    if($this.Location.x -ge $item.Location.x){
                       if($this.Location.y -ge $item.Location.y){
                            if($this.Location.x -le $item.Location.x + $item.Size.Width - ($this.Size.Width/2)){
                                if($this.Location.y -le $item.Location.y + $item.Size.Height - ($this.Size.Height/2)){
                                    if($item.Name -eq "TABCTRL_"){
                                        $ctrl = $item.Controls[0]
                                        $locdif = $this.location - $item.Location
                                        $ctrl.TabPages[$ctrl.SelectedIndex].Controls.AddRange(@($this) + $ctrl.TabPages[$ctrl.SelectedIndex].Controls)
                                        $this.Tag = "TABCTRL_"
                                        $this.Location=$locdif
                                    }elseif($item.GetType().ToString() -in @("System.Windows.Forms.Panel","System.Windows.Forms.GroupBox")){
                                        $locdif = $this.location - $item.Location
                                        $item.Controls.AddRange(@($this) + $item.Controls)
                                        $this.Location=$locdif
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

}
function NewItem_DoubleClick{
    Write-Host "This doesn't work saddly..."
}
function PropValue_ChangeColor{
    $ColorDialog = New-Object System.Windows.Forms.ColorDialog
    $ColorDialog.ShowDialog()
    $ColorDialog.Color
    $prop = $PropOwner.GetType().GetProperty($this.Name)
    $prop.SetValue($PropOwner,$ColorDialog.Color)
    $this.BackColor = $ColorDialog.Color
    $this.ForeColor = $ColorDialog.Color
    $ColorDialog.Dispose()
}
function PropValue_ChangeFont{
    $FontDialog = New-Object System.Windows.Forms.FontDialog
    $FontDialog.ShowDialog()
    $FontDialog.Font
    $prop = $PropOwner.GetType().GetProperty($this.Name)
    $prop.SetValue($PropOwner,$FontDialog.Font)
    $this.Text = $FontDialog.Font.FontFamily.Name
    $this.Font = $FontDialog.Font
    $FontDialog.Dispose()
}

function PropValue_Change{
    $prop = $PropOwner.GetType().GetProperty($this.Name)
    $PropType= $prop.ToString().Split(" ")[0]
    $PropTypeX= $prop.ToString().Split(" ")[1]
    if($PropType -eq "Boolean"){
        $bool = $true
        if($this.text -eq "False"){$bool = $false}
        if($PropTypeX -eq "AutoSize"){
            $PropOwner.AutoSize = $bool
        }
        else {$prop.SetValue($PropOwner,$bool)}
    }
    elseif($PropType -eq "System.String") {$prop.SetValue($PropOwner,$this.Text)}
    elseif($PropType -eq "Int32") {$prop.SetValue($PropOwner,([int]$this.Text))}
    elseif($PropType -eq "System.Windows.Forms.BorderStyle"){
        $BStyle = [System.Windows.Forms.BorderStyle]::None
        if($this.text -eq "Fixed3D"){
            $BStyle = [System.Windows.Forms.BorderStyle]::Fixed3D
        }elseif($this.text -eq "FixedSingle"){
            $BStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
        }
        $prop.SetValue($PropOwner,$BStyle)
        
    }elseif($PropType -eq "System.Drawing.ContentAlignment"){
        $Align
        if($this.text -eq "TopLeft"){
            $Align = [System.Drawing.ContentAlignment]::TopLeft
        }elseif($this.text -eq "TopCenter"){
            $Align = [System.Drawing.ContentAlignment]::TopCenter
        }elseif($this.text -eq "TopRight"){
            $Align = [System.Drawing.ContentAlignment]::TopRight
        }elseif($this.text -eq "MiddleLeft"){
            $Align = [System.Drawing.ContentAlignment]::MiddleLeft
        }elseif($this.text -eq "MiddleCenter"){
            $Align = [System.Drawing.ContentAlignment]::MiddleCenter
        }elseif($this.text -eq "MiddleRight"){
            $Align = [System.Drawing.ContentAlignment]::MiddleRight
        }elseif($this.text -eq "BottomLeft"){
            $Align = [System.Drawing.ContentAlignment]::BottomLeft
        }elseif($this.text -eq "BottomCenter"){
            $Align = [System.Drawing.ContentAlignment]::BottomCenter
        }else{
            $Align = [System.Drawing.ContentAlignment]::BottomRight
        }
        $prop.SetValue($PropOwner,$Align)
    }elseif($PropType -eq "System.Windows.Forms.Appearance"){
        $BAppearance = [System.Windows.Forms.Appearance]::Normal
        if($this.text -eq "Button"){
            $BAppearance = [System.Windows.Forms.Appearance]::Button
        }
        $prop.SetValue($PropOwner,$BAppearance)
    }elseif($PropType -eq "System.Windows.Forms.AnchorStyles"){
        $TSplit = $this.Text.Split(", ")
        $Anchors
        foreach($item in $TSplit){
            if($item -eq "Left"){$Anchors=$Anchors -bor [System.Windows.Forms.AnchorStyles]::Left}
            elseif($item -eq "Right"){$Anchors=$Anchors -bor [System.Windows.Forms.AnchorStyles]::Right}
            elseif($item -eq "Bottom"){$Anchors=$Anchors -bor [System.Windows.Forms.AnchorStyles]::Bottom}
            elseif($item -eq "Top"){$Anchors=$Anchors -bor [System.Windows.Forms.AnchorStyles]::Top}
            elseif($item -eq "None"){$Anchors=$Anchors -bor [System.Windows.Forms.AnchorStyles]::None}
        }
        $prop.SetValue($PropOwner,$Anchors)
    }elseif($PropType -eq "System.Windows.Forms.DockStyle"){
        $Dock
        if($this.Text -eq "Left"){$Dock=[System.Windows.Forms.DockStyle]::Left}
        elseif($this.Text -eq "Right"){$Dock=[System.Windows.Forms.DockStyle]::Right}
        elseif($this.Text -eq "Bottom"){$Dock=[System.Windows.Forms.DockStyle]::Bottom}
        elseif($this.Text -eq "Top"){$Dock=[System.Windows.Forms.DockStyle]::Top}
        elseif($this.Text -eq "None"){$Dock=[System.Windows.Forms.DockStyle]::None}
        elseif($this.Text -eq "Fill"){$Dock=[System.Windows.Forms.DockStyle]::Fill}
        $prop.SetValue($PropOwner,$Dock)
    }
    Write-Host $prop.Name
    #$bool = New-Object System.Management.Automation.PSMethod
    #$bool.Value=$true
}
$FormBorder = New-Object System.Windows.Forms.Label
$FormBorder.Location = Point(200) (45)
$FormBorder.Name = "FormBorder"
$FormBorder.Size = Size(410) (305)
$FormBorder.BackColor = [System.Drawing.Color]::FromArgb(180,180,180)
$FormBorder.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D
#$FormBorder.Add_MouseHover
$FormBorder.Add_MouseMove({FormBorder_MouseHover})
$FormBorder.Add_MouseDown({FormBorder_MouseDown})
$FormBorder.Add_MouseUp({FormBorder_MouseUp})

$FormBorder.Cursor = [System.Windows.Forms.Cursors]::SizeWE

$FormTitlebar = New-Object System.Windows.Forms.Label
$FormTitlebar.Location = Point(200) (25)
$FormTitlebar.Size = Size(410) (20)
$FormTitlebar.Text = "  PowerShell Form"
$FormTitlebar.BackColor = [System.Drawing.Color]::FromArgb(200,200,200)
$global:Numbers = 1
Function FormPanel_MouseClick{
    if($FormList.SelectedIndex -gt -1){
        $item = $FormList.Items[$FormList.SelectedIndex]
        $cmd = '$NewLabel = New-Object System.Windows.Forms.' + $item
        Invoke-Expression $cmd

        
        if($NewLabel.GetType().ToString() -eq "System.Windows.Forms.TabControl"){ #TabControl
            $NewLabel = New-Object System.Windows.Forms.Label
            $NewLabel.Tag = "TabControl"
            $TabCtrl = New-Object System.Windows.Forms.TabControl
            $TabCtrl.AutoSize = $true
            $TabPage = New-Object System.Windows.Forms.TabPage
            $TabPage.Text = "Tab Page"
            $TabCtrl.Controls.Add($TabPage)
            $NewLabel.Controls.Add($TabCtrl)
            $NewLabel.Size = $TabCtrl.Size
            $TabCtrl.Size = $NewLabel.Size
            $TabCtrl.Name="TabControl" + $global:Numbers.ToString()
            $global:Numbers++
            $TabPage.Name = "TabPage" +$global:Numbers.ToString()
            $global:Numbers++

            $NewLabel.Name = "TABCTRL_"
            $NewLabel.Text = "...................    +"
            $TabCtrl.Tag = "TABCTRL_"
            
        }
        #>
        $MousePos = GetMousePos
        $NewLabel.Location = Point ($MousePos.x - $FormPanel.Location.x-$DLM.Location.x) ($MousePos.y-$FormPanel.Location.y-$DLM.Location.y)
        #Write-Host $NewLabel.Location
        if($FormList.SelectedIndex -ne 15){
            $NewLabel.Size = Size 120 40
            $NewLabel.Text = ("New " + $FormList.Items[$FormList.SelectedIndex])
            $NewLabel.Name = $FormList.Items[$FormList.SelectedIndex] + $global:Numbers.ToString()
            $global:Numbers++
        }
        if($FormList.SelectedIndex -notin @(-1,0,1,15)){
            #Write-Host "Not in?"
            $NewLabel.BorderStyle = 2
        }
        $NewLabel.Add_MouseMove({NewItem_MouseMove})
        $NewLabel.Add_MouseDown({NewItem_MouseDown})
        $NewLabel.Add_MouseUp({NewItem_MouseUp})
        $NewLabel.Add_DoubleClick({NewItem_DoubleClick})
        $NewLabel.ContextMenu = $RClickMenu
        $FormList.SelectedIndex = -1
        $FormPanel.Controls.Add($NewLabel)
    }
}
function Obj_ToFront{
    if($global:PropOwner -ne $null){
        $parent = FindParentControl -child_form $global:PropOwner -src $FormPanel
        #Write-Host $parent.Name
        $parent.Controls.Remove($global:PropOwner)
        $parent.Controls.AddRange(@($global:PropOwner)+$parent.Controls)
    }
}

function Obj_ToBack{
    if($global:PropOwner -ne $null){
        $parent = FindParentControl -child_form $global:PropOwner -src $FormPanel
        #Write-Host $parent.Name
        $parent.Controls.Remove($global:PropOwner)
        $parent.Controls.Add($global:PropOwner)
    }
}

function Obj_Delete{
    if($global:PropOwner -ne $null){
        if($global:PropOwner.GetType().ToString() -eq "System.Windows.Forms.TabControl"){
            $parent = FindParentControl -child_form $global:PropOwner
            $parent.Dispose()
        }
        $global:PropOwner.Dispose()
    }
}

function View_Code{
    if($FormCode.Visible){
        $FormCode.Visible = $false
        $FormCode.Enabled = $false
        $View_Code.Text = "Code"
    }else {
        $FormCode.Visible = $true
        $FormCode.Enabled = $true
        $View_Code.Text = "Form"

        DLM_Save

        $FormCode.Text = ""
        $IOStream = New-Object System.IO.StreamReader "NewForm.ps1"
        $line = 1
        while (($getline =$IOStream.ReadLine()) -ne $null)
        {
            if($line -gt 1){
                $FormCode.AppendText([System.Environment]::NewLine)
            }
            $FormCode.AppendText($getline)

            $line++
        }
        $IOStream.Close()
    }
}

function FindParentControl{
    param ($child_form,$src)
    if($child_form -ne $null){
        $found_parent = $null
        if($src -eq $null){$src = $FormPanel}
        foreach($item in $src.Controls){
            if($item -eq $child_form){
                return $src
            }else{
                if($item.Controls.Count -gt 0){
                    FindParentControl -child_form $child_form -src $item
                }
            }
        }
    }
}

#########################################################################
######################## Right Click Menu
$RClickMenu = New-Object System.Windows.Forms.ContextMenu
$RClickMenu.MenuItems.AddRange(@("Bring To Front","Send To Back","Delete"))
$RClickMenu.MenuItems[0].Add_Click({Obj_ToFront})
$RClickMenu.MenuItems[1].Add_Click({Obj_ToBack})
$RClickMenu.MenuItems[2].Add_Click({Obj_Delete})
#########################################################################
######################## Form Builder & Properties
$FormPanel = New-Object System.Windows.Forms.Panel
$FormPanel.Location = Point 205 45
$FormPanel.Size = Size 400 300
$FormPanel.Name ="FormPanel"
$FormPanel.BackColor = [System.Drawing.Color]::FromArgb(230,230,230)
$FormPanel.Add_MouseClick({FormPanel_MouseClick})

$FormCode =  New-Object System.Windows.Forms.RichTextBox
$FormCode.Location = Point 205 45
$FormCode.Size = Size 400 300
$FormCode.Name = "FormCode"
$FormCode.Visible = $false
$FormCode.Enabled = $false
$FormCode.WordWrap = $true

$FormList =New-Object System.Windows.Forms.ListBox
$FormList.Location = Point 0 25
$FormList.Size = Size 200 575
$FormList.Items.AddRange(@("Button","CheckBox", "CheckedListBox","ContextMenu", "DataGridView","DateTimePicker","GroupBox","HScrollBar","Label","ListBox","ListView","Menu","PictureBox","ProgressBar","RadioButton","TabControl","TextBox","TrackBar","TreeView","VScrollBar","Panel"))
$FormList.Font = New-Object System.Drawing.Font("Arial",14)
#

$DLM = new-object System.Windows.Forms.form
$DLM.BackColor = [System.Drawing.Color]::FromArgb(80,80,80)
#
$FormProperties = New-Object System.Windows.Forms.Panel
$FormProperties.Location = Point 750 25
$FormProperties.Size = Size 250 600
$FormProperties.BackColor = [System.Drawing.Color]::FromArgb(255,255,255)
$FormProperties.Anchor=([System.Windows.Forms.AnchorStyles]::Right + [System.Windows.Forms.AnchorStyles]::Top)
$FormProperties.AutoScroll = $true

#########################################################################
######################## Menu Strip
$DLMMenu = New-Object System.Windows.Forms.MenuStrip
$DLMMenu.Location = Point 0 0
$DLMMenu.Name = "DLMMenu"
$DLMMenu.TabIndex = 0
$Menu_File = New-Object System.Windows.Forms.ToolStripMenuItem
$Menu_File.Text = "File"
$File_Exit = New-Object System.Windows.Forms.ToolStripMenuItem
$File_Exit.Text = "Exit"
$File_Exit.Add_Click({$DLM.Close()})
$File_Save = New-Object System.Windows.Forms.ToolStripMenuItem
$File_Save.Text = "Save"
$File_Save.Add_Click({DLM_Save})
$File_SaveAs = New-Object System.Windows.Forms.ToolStripMenuItem
$File_SaveAs.Text = "Save As.."
$File_SaveAs.Add_Click({DLM_Save($true)})
$File_Load = New-Object System.Windows.Forms.ToolStripMenuItem
$File_Load.Text = "Load"
$File_Load.Add_Click({DLM_Load})
$Menu_File.DropDownItems.AddRange(@($File_Save,$File_SaveAs,$File_Load,$File_Exit))

$Menu_Obj = New-Object System.Windows.Forms.ToolStripMenuItem
$Menu_Obj.Text = "Objects"
$Obj_Delete = New-Object System.Windows.Forms.ToolStripMenuItem
$Obj_Delete.Text = "Delete Object"
$Obj_Delete.Add_Click({Obj_Delete})
$Obj_ToFront = New-Object System.Windows.Forms.ToolStripMenuItem
$Obj_ToFront.Text = "Bring Object To Front"
$Obj_ToFront.Add_Click({Obj_ToFront})
$Obj_ToBack = New-Object System.Windows.Forms.ToolStripMenuItem
$Obj_ToBack.Text = "Bring Object To Front"
$Obj_ToBack.Add_Click({Obj_ToFront})
$Menu_Obj.DropDownItems.AddRange(@($Obj_ToBack,$Obj_ToFront,$Obj_Delete))

$Menu_View = New-Object System.Windows.Forms.ToolStripMenuItem
$Menu_View.Text = "View"
$View_Code = New-Object System.Windows.Forms.ToolStripMenuItem
$View_Code.Text = "Code"
$View_Code.Add_Click({View_Code})
$Menu_View.DropDownItems.AddRange(@($View_Code))

$DLMMenu.Items.AddRange(@($Menu_File,$Menu_Obj,$Menu_View))
#########################################################################
######################## Main Form



$DLM.ClientSize = new-object System.Drawing.Size(1000, 600)
$DLM.Controls.AddRange(@($DLMMenu,$FormList, $FormTitlebar,$FormProperties,$global:ObjSelect, $FormCode, $FormPanel,$FormBorder))
$DLM.MainMenuStrip = $DLMMenu
$DLM.Name = "PowerShell-DLM"
$DLM.Text = "PowerShell-DLM"

#########################################################################
######################## Loop
$MainLoop = New-Object System.Windows.Forms.Timer
$MainLoop.Interval = 100

$MainLoop.Add_Tick({MainLoop})
$global:NotDoubleClick = $false
function MainLoop{
    if($global:Resizing){
        $MousePos = [System.Windows.Forms.Cursor]::Position
        $GetSize = $global:MDSize
        $global:ResizeTarg.Size = Size (($MousePos.X - $global:MDPos.X) + $GetSize.Width) (($MousePos.Y - $global:MDPos.Y) + $GetSize.Height)
        if($global:ResizeTarg.Name -eq "FormBorder"){
            $FormPanel.Size = Size (($MousePos.X - $global:MDPos.X) + $GetSize.Width-10) (($MousePos.Y - $global:MDPos.Y) + $GetSize.Height-5)
            $FormCode.Size = $FormPanel.Size
            $FormTitlebar.Size = Size (($MousePos.X - $global:MDPos.X) + $GetSize.Width) (20)
            
        }elseif($global:ResizeTarg.Name -eq "TABCTRL_"){
            #Write-Host "Resize all!"
            foreach($item in $global:ResizeTarg.Controls){
                $item.Size = $global:ResizeTarg.Size
            }
        }
        #Write-Host $global:ResizeTarg.Name
    }elseif($global:Moving){
        $MousePos = [System.Windows.Forms.Cursor]::Position
        $Diff = $MousePos - $global:MDPos
        $global:MoveTarg.Location = Point ($global:MoveTarg.Location.x+$Diff.x) ($global:MoveTarg.Location.y+$Diff.y)
        $global:MDPos = $MousePos
     }
     if($global:DoubleClick){
        if($global:NotDoubleClick){
            $global:DoubleClick = $false
            $global:NotDoubleClick = $false
        }else {$global:NotDoubleClick = $true}
     }elseif($global:NotDoubleClick) {$global:NotDoubleClick = $false}
}

function Activate{
   
    $MainLoop.Start()
}


#########################################################################
######################## Saving & Loading
$global:FileSave = "NewForm.ps1"
function DLM_Load{
    $FormPanel.Controls.Clear()
    $FileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $FileDialog.Filter = "txt files (*.txt)|*.txt|PowerShell (*.ps1)|*.ps1"
    $FileDialog.FilterIndex = 2
    $FileDialog.ShowDialog()
    $IOStream = New-Object System.IO.StreamReader $FileDialog.FileName
    $global:FileSave = $FileDialog.FileName
    $FileDialog.Dispose()
    $line = 1
    while (($getline =$IOStream.ReadLine()) -ne $null)
    {
        $line++
        if($getline.Contains("MainForm")){
            if($getline.Contains(".Controls")){
                $newexp = $getline.Replace("MainForm","FormPanel")
                Write-Host $newexp
                Invoke-Expression $newexp
            }
            Write-Host $getline
        }
        elseif($getline.Contains("=")){
            $cmdsplit = $getline.Split("=")
            $cmdsplit[0] = $cmdsplit[0].Replace(" ","")
            if($cmdsplit[1] -ne " "){
                $getline = $cmdsplit[0]+" ="+$cmdsplit[1]
                if($getline.Contains("MainForm = New-Object") -eq $false){
                    $newexp = $getline.Replace("MainForm","FormPanel")
                    $newexp = $newexp.Replace("ClientSize","Size")
                    #Write-Host $newexp
                    Invoke-Expression $newexp

                    if($newexp.Contains("New-Object")){
                        $global:Numbers++
                        $addfunc = $newexp.Split(" =")[0]
                        if($addfunc.Contains(".") -eq $false){
                            #$addfunc =  $addfunc + ".Add_MouseDown({NewItem_MouseDown});"+$addfunc+".Add_MouseUp({NewItem_MouseUp});"+$addfunc+".Add_DoubleClick({NewItem_DoubleClick})"
                            
                            Invoke-Expression ($addfunc + ".Add_MouseMove({NewItem_MouseMove})")
                            Invoke-Expression ($addfunc + ".Add_MouseDown({NewItem_MouseDown})")
                            Invoke-Expression ($addfunc + ".Add_MouseUp({NewItem_MouseUp})")
                            Invoke-Expression ($addfunc+'.ContextMenu = $RClickMenu')

                        }
                    }
                }
            }
        }elseif($getline.Contains(".Controls")){
            $newexp = $getline.Replace("MainForm","FormPanel")
            Write-Host $newexp
            Invoke-Expression $newexp
        }
    }
    $IOStream.Close()

    $FormBorder.Height = $FormPanel.Height+5
    $FormBorder.Width = $FormPanel.Width+10
    $FormPanel.Name="FormPanel"
    $FormTitlebar.Width=$FormBorder.Width
    $DLM.Width = $FormBorder.Width+500
    
    $FileDialog.Dispose()
    foreach($item in $FormPanel.Controls){
        Write-Host $item.GetType()
        if($item.GetType().ToString() -eq "System.Windows.Forms.TabControl"){
            $NewLabel = New-Object System.Windows.Forms.Label
            $NewLabel.Tag = "TabControl"
            $FormPanel.Controls.Add($NewLabel)
            $NewLabel.Location = $item.Location
            $NewLabel.Controls.Add($item)
            $NewLabel.Size = $item.Size
            $item.Size = $NewLabel.Size
            #Write-Host "TABCTRL_ Created"
            $item.Location = Point 0 0
            $NewLabel.Name = "TABCTRL_"
            
            $NewLabel.BackColor = [System.Drawing.Color]::FromArgb(20,20,20)
            $NewLabel.Add_MouseMove({NewItem_MouseMove})
            $NewLabel.Add_MouseHover({NewItem_MouseHover})
            $NewLabel.Add_MouseDown({NewItem_MouseDown})
            $NewLabel.Add_MouseUp({NewItem_MouseUp})
            $NewLabel.Add_DoubleClick({NewItem_DoubleClick})
            

        }
    }
    
}

function DLM_Save{
    #Write-Host "Wish this was ez"
    param($saveas)
    if($saveas){
        $FileDialog = New-Object System.Windows.Forms.SaveFileDialog
        $FileDialog.Filter = "txt files (*.txt)|*.txt|PowerShell (*.ps1)|*.ps1"
        $FileDialog.FilterIndex = 2
        $FileDialog.ShowDialog()
        $global:FileSave = $FileDialog.FileName
        $FileDialog.Dispose()
    }
    $MainFormOut = '[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")'+"`n"+'[void][Reflection.Assembly]::LoadWithPartialName("System.Drawing")'+"`n"+"Add-Type -AssemblyName PresentationCore,PresentationFramework`n"
    $MainFormOut = $MainFormOut + '$MainForm = New-Object System.Windows.Forms.Form'+"`n"
    $MainFormOut = $MainFormOut + '$MainForm.ClientSize = New-Object System.Drawing.Point(' + $FormPanel.Size.Width+','+$FormPanel.Size.Height+")`n"
    $MainFormOut =$MainFormOut + '$MainForm.Name = "Main Form (DLM)"' +"`n" + '$MainForm.Text = "Main Form - Title"' + "`n"
    $Controls = OutputControls -Form $FormPanel
    ($MainFormOut+$Controls+"`n"+'$MainForm.ShowDialog()') | Out-File $global:FileSave
}
$UnsupportedVariables = @("FirstDisplayedScrollingRowIndex","GridColor","IsCurrentCellDirty","IsCurrentCellInEditMode","RowsDefaultCellStyle","RowHeadersDefaultCellStyle","RowTemplate","TopLeftHeaderCell","SelectedText","Tag","Item","StateImageList","SelectedNode","TreeViewNordeSorter","TopNode","ContextMenu","LineColor","DialogResult","AutoScrollMinSize","AutoScrollPosition","AutoScrollMargin","DataSource","FormatInfo","AutoCompleteCustomSource","Site","RightToLeft","ImeMode","AutoSizeMode","Cursor","DisplayRectangle","Size","Location","ClientSize","AccessibleDefaultActionDescription","Region","Container","Padding","PreferredSize","WindowTarget","TopLevelControl","RecreatingHandle","ProductVersion","ProductName","Parent","MaximumSize","MinimumSize","Margin","IsMirrored","IsAccessible","InvokeRequired","IsHandleCreated","HasChildren","Handle","Disposing","IsDisposed","DeviceDpi","DataBindings","Created","Controls","ContextMenuStrip","ContextMenu","ContainsFocus","CompanyName","ClientRectangle","CausesValidation","Capture","Bounds","BindingContext","BackgroundImageLayout","BackgroundImage","LayoutEngine","AutoScrollOffset","AccessibleRole","AccessibleName","AccessibleDescription","AccessibleEfaultActionDescription","AccessibilityObject","UseVisualStyleBackColor","UseCompatibleTextRendering","TextImageRelation","Image","ImageAlign","ImageKey","ImageList","TreeViewNodeSorter")
$ReadOnlyVariables = @("SelectedColumns","Rows","IsCurrentRowDirty","NewRowIndex","SelectedRows","SortOrder","UserSetCursor","VerticalScrollingOffset","Nodes","FlatAppearance","VisibleCount","CustomTabOffsets","SelectedIndices","TabPages","TabCount","RowCount","ItemSize","DockPadding","VerticalScroll","HorizontalScroll","SelectedItems","Items","Site","Right","Focused","CanSelect","CanFocus","Bottom","TextLength","PreferredHeight","PreferredWidth","CanUndo")
$UnsupportedVariables = $UnsupportedVariables + $ReadOnlyVariables
function OutputControls{
    param ($Form, $parent)
    $output = $null
    if($Form.Name -in @("TABCTRL_","FormPanel")){
        $controls = '$MainForm.Controls.AddRange(@('
    }else {$controls = '$'+$Form.Name + ".Controls.AddRange(@("}

    $count=0
    foreach($item in $Form.Controls){
        $item.Name = $item.Name.Replace(" ","")
        if($item.Name -ne "TABCTRL_"){
            $count++
            $output = $output + "$" + $item.Name + " = New-Object " + $item.GetType()+"`n"
            $output = $output + (OutputControls -Form $item -parent $Form)+"`n"
            foreach($prop in $item.GetType().GetProperties()){
                $ePropName = $prop.Name
                [Int32]$OutNumber = $null
                if($ePropName -notin $UnsupportedVariables){
                    $ePropValue = $prop.GetValue($item)

                    if($ePropName -in @("Left","Top")){
                        if($parent.Name -eq "TABCTRL_"){
                            #Write-Host "Update location " + ($parent.Left.ToString() +" _ " +$parent.Top.ToString())
                            if($ePropName -eq "Left"){$ePropValue = $parent.Left}
                            else {$ePropValue = $parent.Top}
                        }
                    }
                    
                    if($ePropValue -ne $null -and $ePropValue.ToString() -ne ""){
                        #Write-Host $item.GetType()
                        if($ePropValue.ToString() -eq "True"){$ePropValue = '$true'}
                        elseif($ePropValue.ToString() -eq "False"){$ePropValue = '$false'}
                        elseif($ePropName -eq "System.Windows.Forms.Appearance"){$ePropValue = '[System.Windows.Forms.Appearance]::' + $ePropValue}
                        elseif([Int32]::TryParse($ePropValue,[ref]$OutNumber)){$ePropValue = $OutNumber}
                        elseif($ePropName -eq "TextAlign"){
                            if($item.GetType().ToString() -ne "System.Windows.Forms.TextBox"){$ePropValue = '[System.Drawing.ContentAlignment]::' + $ePropValue}
                            else { $ePropValue = '[System.Windows.Forms.HorizontalAlignment]::' + $ePropValue}
                        }
                        elseif($ePropName -eq "Font"){$ePropValue = "[System.Drawing.Font]::new("+'"'+$ePropValue.FontFamily.Name+'"'+","+$ePropValue.Size.ToString()+",[System.Drawing.FontStyle]::" +$ePropValue.Style.ToString() +")"}
                        elseif($ePropName -in @("BackColor","ForeColor")){$ePropValue = '[System.Drawing.Color]::FromArgb('+$ePropValue.R.ToString()+","+$ePropValue.G.ToString()+","+$ePropValue.B.ToString()+")"}
                        else {$ePropValue = '"' +$ePropValue +'"'}
                    }
                    $output = $output + ("$"+$item.Name + "." + $ePropName +" = " + $ePropValue)+"`n"
                }
            }
            if($count -eq 1){
                $controls = $controls + "$"+ $item.Name
            }else {
                $controls = $controls + ",$" + $item.Name
            }
        }else{
            $output = $output + (OutputControls -Form $item)+"`n"
        }
    }
    if($Form.Controls.Count -gt 0){
        
        $output = $output + $controls + "))`n"
    }
    #Write-Host ($Form.Controls.Count.ToString() + "`n" + $Form.Name)
    return $output
}

$DLM.Add_Shown({Activate})
$DLM.ShowDialog()
#Free ressources
$DLM.Dispose()

$MainLoop.Dispose()