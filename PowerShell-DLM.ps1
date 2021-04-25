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
MsgBox "Hello world."

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

#
$global:MDPos
$global:MDSize
$global:MDLoc
$global:Resizing
$global:ResizeTarg
$global:PropOwner
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
    $MousePos_X = [System.Windows.Forms.Cursor]::Position.X
    $MousePos_Y = [System.Windows.Forms.Cursor]::Position.Y
    
    $LeftEdge = $this.Location.X + $DLM.Location.X + $FormPanel.Location.X
    $RightEdge = $this.Location.X + $DLM.Location.X + $FormPanel.Location.X + $this.Size.Width
    $TopEdge = $this.Location.Y + $DLM.Location.Y +$FormPanel.Location.Y
    $BottomEdge = $this.Location.Y + $DLM.Location.Y +$FormPanel.Location.Y+$DLMMenu.Size.Height+ $this.Size.Height
    $FormTitlebar.Text = ($MousePos_X.ToString() +"," +$MousePos_Y.ToString() + "|" + $BottomEdge.ToString())
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
    $MousePos_X = [System.Windows.Forms.Cursor]::Position.X
    $MousePos_Y = [System.Windows.Forms.Cursor]::Position.Y
    $LeftEdge = $this.Location.X + $DLM.Location.X + $FormPanel.Location.X
    $RightEdge = $this.Location.X + $DLM.Location.X + $FormPanel.Location.X + $this.Size.Width
    $TopEdge = $this.Location.Y + $DLM.Location.Y +$FormPanel.Location.Y
    $BottomEdge = $this.Location.Y + $DLM.Location.Y +$FormPanel.Location.Y+$DLMMenu.Size.Height+ $this.Size.Height
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
    
    #################### Populate "Properties" window ($FormProperties) ##################
    if($global:PropOwner -ne $this){
        foreach($item in $FormProperties.Controls){
            
            $item.Dispose()
        }
        $FormProperties.Controls.Clear()
        $NextY = 0
        $global:PropOwner = $this
        foreach($prop in $this.GetType().GetProperties()){
        
            $ePropName = $prop.Name
            if($ePropName -notin $UnsupportedVariables){
                $ePropValue = $prop.GetValue($this)

                $PropLabel = New-Object System.Windows.Forms.Label
                $PropLabel.Location = Point 0 $NextY
                $PropLabel.Size = Size 100 25
                $PropLabel.Text = $ePropName
                $PropLabel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
                $PropType= $prop.ToString().Split(" ")[0]
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
                }
        
                else {
                    #Write-Host $PropType
                    $PropValue = New-Object System.Windows.Forms.TextBox
                    $ePropValue = $PropType
                }
                if($PropValue -ne $null){
                    $PropValue.Text = $ePropValue
                    $PropValue.Name = $ePropName
                    $PropValue.Location = Point 100 $NextY
                    $PropValue.Size = Size 130 25
                    #$FormBorder.LostFocus
                    $PropValue.Add_LostFocus({PropValue_LostFocus})
                    $PropValue.Add_Enter({PropValue_LostFocus})
                    $PropValue.Add_TextChanged({PropValue_LostFocus})
        
                    $FormProperties.Controls.AddRange(@($PropLabel,$PropValue))
                }
                $NextY = $NextY + 25
            }
        }
    }
}

$global:DoubleClick = $false
function NewItem_MouseUp{
    if($global:DoubleClick){
        $global:DoubleClick = $false
        Write-Host "Insert DoubleClick action..."
    }else {$global:DoubleClick = $true}
    if($global:ResizeTarg -ne $null){
        $global:ResizeTarg.Cursor = [System.Windows.Forms.Cursors]::Default
    }
    $this.Cursor = [System.Windows.Forms.Cursors]::Default
    $global:Resizing = $false
    $global:Moving = $false
    if($this -in $FormPanel.Controls){
        foreach($item in $FormPanel.Controls){
            if($item.Name -eq "TABCTRL_" -and $this -ne $item){
                if($this.Location.x -ge $item.Location.x){
                    Write-Host "Great X"
                    if($this.Location.y -ge $item.Location.y){
                        Write-Host "Great Y"
                        if($this.Location.x -le $item.Location.x + $item.Size.Width - ($this.Size.Width/2)){
                            if($this.Location.y -le $item.Location.y + $item.Size.Height - ($this.Size.Height/2)){
                                foreach($ctrl in $item.Controls){
                                    $locdif = $this.location - $ctrl.Location
                                    $ctrl.TabPages[$ctrl.TabIndex].Controls.Add($this)
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

function PropValue_LostFocus{
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
        
    }
    #$bool = New-Object System.Management.Automation.PSMethod
    #$bool.Value=$true
}
$FormBorder = New-Object System.Windows.Forms.Label
$FormBorder.Location = Point(200) (25)
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
        
        if($FormList.SelectedIndex -eq 0){ #Button
            $NewLabel = New-Object System.Windows.Forms.Button
        }elseif($FormList.SelectedIndex -eq 1){ #CheckBox
            $NewLabel = New-Object System.Windows.Forms.CheckBox
        }elseif($FormList.SelectedIndex -eq 2){ #CheckedListBox
            $NewLabel = New-Object System.Windows.Forms.CheckedListBox
        } elseif($FormList.SelectedIndex -eq 3){ #ContextMenu
            $NewLabel = New-Object System.Windows.Forms.ContextMenu
        } elseif($FormList.SelectedIndex -eq 4){ #DataGridView
            $NewLabel = New-Object System.Windows.Forms.DataGridView
        } elseif($FormList.SelectedIndex -eq 5){ #DateTimePicker
            $NewLabel = New-Object System.Windows.Forms.DateTimePicker
        } elseif($FormList.SelectedIndex -eq 6){ #GroupBox
            $NewLabel = New-Object System.Windows.Forms.GroupBox
        } elseif($FormList.SelectedIndex -eq 7){ #HScrollBar
            $NewLabel = New-Object System.Windows.Forms.HScrollBar
        } elseif($FormList.SelectedIndex -eq 8){ #Label
            $NewLabel = New-Object System.Windows.Forms.Label
        } elseif($FormList.SelectedIndex -eq 9){ #ListBox
            $NewLabel = New-Object System.Windows.Forms.ListBox
        } elseif($FormList.SelectedIndex -eq 10){ #ListView
            $NewLabel = New-Object System.Windows.Forms.ListView
        } elseif($FormList.SelectedIndex -eq 11){ #Menu
            $NewLabel = New-Object System.Windows.Forms.Menu
        } elseif($FormList.SelectedIndex -eq 12){ #PictureBox
            $NewLabel = New-Object System.Windows.Forms.PictureBox
        } elseif($FormList.SelectedIndex -eq 13){ #ProgressBar
            $NewLabel = New-Object System.Windows.Forms.ProgressBar
        } elseif($FormList.SelectedIndex -eq 14){ #RadioButton
            $NewLabel = New-Object System.Windows.Forms.RadioButton
        } elseif($FormList.SelectedIndex -eq 15){ #TabControl
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
            $NewLabel.Text = "........    +"
            $TabCtrl.Tag = "TABCTRL_"
            
        } elseif($FormList.SelectedIndex -eq 16){ #TextBox
            $NewLabel = New-Object System.Windows.Forms.TextBox
        } elseif($FormList.SelectedIndex -eq 17){ #TrackBar
            $NewLabel = New-Object System.Windows.Forms.TrackBar
        } elseif($FormList.SelectedIndex -eq 18){ #TreeView
            $NewLabel = New-Object System.Windows.Forms.TreeView
        } elseif($FormList.SelectedIndex -eq 19){ #VScrollBar
            $NewLabel = New-Object System.Windows.Forms.VScrollBar
        } 
        
        $MousePos = GetMousePos
        $NewLabel.Location = Point ($MousePos.x - $FormPanel.Location.x-$DLM.Location.x) ($MousePos.y-$FormPanel.Location.y-$DLM.Location.y)
        #Write-Host $NewLabel.Location
        if($FormList.SelectedIndex -ne 15){
            $NewLabel.Size = Size 120 40
            $NewLabel.Text = ("New " + $FormList.Items[$FormList.SelectedIndex])
            $NewLabel.Name = $FormList.Items[$FormList.SelectedIndex] + $global:Numbers.ToString()
            $global:Numbers++
        }
        if($FormList.SelectedIndex -notin @(-1,0,15)){
            #Write-Host "Not in?"
            $NewLabel.BorderStyle = 2
        }
        $NewLabel.Add_MouseMove({NewItem_MouseMove})
        $NewLabel.Add_MouseDown({NewItem_MouseDown})
        $NewLabel.Add_MouseUp({NewItem_MouseUp})
        $NewLabel.Add_DoubleClick({NewItem_DoubleClick})
        $FormList.SelectedIndex = -1
        $FormPanel.Controls.Add($NewLabel)
    }
}
$FormPanel = New-Object System.Windows.Forms.Panel
$FormPanel.Location = Point 205 25
$FormPanel.Size = Size 400 300
$FormPanel.Name ="FormPanel"
$FormPanel.BackColor = [System.Drawing.Color]::FromArgb(230,230,230)
$FormPanel.Add_MouseClick({FormPanel_MouseClick})

$FormList =New-Object System.Windows.Forms.ListBox
$FormList.Location = Point 0 25
$FormList.Size = Size 200 575
$FormList.Items.AddRange(@("Button","CheckBox", "CheckedListBox","ContextMenu", "DataGridView","DateTimePicker","GroupBox","HScrollBar","Label","ListBox","ListView","Menu","PictureBox","ProgressBar","RadioButton","TabControl","TextBox","TrackBar","TreeView","VScrollBar"))
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
$File_Delete = New-Object System.Windows.Forms.ToolStripMenuItem
$File_Delete.Text = "Delete Object"
$File_Delete.Add_Click({if($global:PropOwner -ne $null){$global:PropOwner.Dispose()}})

$Menu_File.DropDownItems.AddRange(@($File_Save,$File_Delete,$File_Exit))

$DLMMenu.Items.AddRange(@($Menu_File))

$DLM.ClientSize = new-object System.Drawing.Size(1000, 600)
$DLM.Controls.AddRange(@($DLMMenu,$FormList, $FormTitlebar,$FormProperties, $FormPanel,$FormBorder))
$DLM.MainMenuStrip = $DLMMenu
$DLM.Name = "PowerShell-DLM"
$DLM.Text = "PowerShell-DLM"
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
function DLM_MouseDown{
    if ($_.Button -eq [System.Windows.Forms.MouseButtons]::Right ) {
            [System.Windows.MessageBox]::Show("Rigth mouse up")
    }
    
}

#$DLM.Add_MouseDown({DLM_MouseDown $sender $EventArgs})
$DLM.Add_MouseDown( {DLM_MouseDown})
function OnFormClosing_DLM($Sender,$e){ 
    # $this represent sender (object)
    # $_ represent  e (eventarg)

    # Allow closing
    Echo "Testing"
    ($_).Cancel= $False
}
function Activate{
   
    $MainLoop.Start()
}
function DLM_Save{
    #Write-Host "Wish this was ez"
    $MainFormOut = '[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")'+"`n"+'[void][Reflection.Assembly]::LoadWithPartialName("System.Drawing")'+"`n"+"Add-Type -AssemblyName PresentationCore,PresentationFramework`n"
    $MainFormOut = $MainFormOut + '$MainForm = New-Object System.Windows.Forms.Form'+"`n"
    $MainFormOut = $MainFormOut + '$MainForm.ClientSize = New-Object System.Drawing.Point(' + $FormPanel.Size.Width+','+$FormPanel.Size.Height+")`n"
    $MainFormOut =$MainFormOut + '$MainForm.Name = "Main Form (DLM)"' +"`n" + '$MainForm.Text = "Main Form - Title"' + "`n"
    $Controls = OutputControls -Form $FormPanel
    ($MainFormOut+$Controls+"`n"+'$MainForm.ShowDialog()') | Out-File "NewForm.ps1"
}
$UnsupportedVariables = @("AutoScrollMinSize","AutoScrollPosition","AutoScrollMargin","DataSource","FormatInfo","AutoCompleteCustomSource","Site","ForeColor","RightToLeft","TextAlign","ImeMode","FlatStyle","BackColor","AutoSizeMode","Cursor","DisplayRectangle","Font","Size","Location","ClientSize","AccessibleDefaultActionDescription","Region","Container","Padding","PreferredSize","WindowTarget","TopLevelControl","RecreatingHandle","ProductVersion","ProductName","Parent","MaximumSize","MinimumSize","Margin","IsMirrored","IsAccessible","InvokeRequired","IsHandleCreated","HasChildren","Handle","Disposing","IsDisposed","DeviceDpi","DataBindings","Created","Controls","ContextMenuStrip","ContextMenu","ContainsFocus","CompanyName","ClientRectangle","CausesValidation","Capture","Bounds","BindingContext","BackgroundImageLayout","BackgroundImage","LayoutEngine","AutoScrollOffset","Anchor","AccessibleRole","AccessibleName","AccessibleDescription","AccessibleEfaultActionDescription","AccessibilityObject","UseVisualStyleBackColor","UseCompatibleTextRendering","TextImageRelation","Image","ImageAlign","ImageKey","ImageList","FlatAppearance","DialogResults")
$ReadOnlyVariables = @("CustomTabOffsets","SelectedIndices","TabPages","TabCount","RowCount","ItemSize","DockPadding","VerticalScroll","HorizontalScroll","SelectedItems","Items","Site","Right","Focused","CanSelect","CanFocus","Bottom","TextLength","PreferredHeight","PreferredWidth","CanUndo")
$UnsupportedVariables = $UnsupportedVariables + $ReadOnlyVariables
function OutputControls{
    param ($Form, $parent)
    $output = $null
    if($Form.Name -in @("TABCTRL_","FormPanel")){
        $controls = '$MainForm.Controls.AddRange(@('
    }else {$controls = '$'+$Form.Name + ".Controls.AddRange(@("}

    $count=0
    foreach($item in $Form.Controls){
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
                            Write-Host "Update location " + ($parent.Left.ToString() +" _ " +$parent.Top.ToString())
                            if($ePropName -eq "Left"){$ePropValue = $parent.Left}
                            else {$ePropValue = $parent.Top}
                        }
                    }
                    
                    if($ePropValue -ne $null){
                        if($ePropValue.ToString() -eq "True"){$ePropValue = '$true'}
                        elseif($ePropValue.ToString() -eq "False"){$ePropValue = '$false'}
                        elseif([Int32]::TryParse($ePropValue,[ref]$OutNumber)){$ePropValue = $OutNumber}
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

$DLM.Add_FormClosing( { OnFormClosing_DLM $DLM $EventArgs} )
$DLM.Add_Shown({Activate})
$DLM.ShowDialog()
#Free ressources
$DLM.Dispose()

$MainLoop.Dispose()