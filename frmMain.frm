VERSION 5.00
Object = "{248DD890-BB45-11CF-9ABC-0080C7E7B78D}#1.0#0"; "mswinsck.ocx"
Begin VB.Form frmMain 
   Caption         =   "RLoginDoor"
   ClientHeight    =   6285
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   10605
   Icon            =   "frmMain.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   ScaleHeight     =   6285
   ScaleWidth      =   10605
   StartUpPosition =   3  'Windows Default
   Begin VB.Timer Timer2 
      Enabled         =   0   'False
      Interval        =   2000
      Left            =   3240
      Top             =   2400
   End
   Begin VB.Timer Timer1 
      Enabled         =   0   'False
      Interval        =   20000
      Left            =   2640
      Top             =   2400
   End
   Begin VB.TextBox Text1 
      BeginProperty Font 
         Name            =   "Courier New"
         Size            =   9
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   6255
      Left            =   0
      MultiLine       =   -1  'True
      ScrollBars      =   2  'Vertical
      TabIndex        =   0
      Top             =   0
      Width           =   10575
   End
   Begin MSWinsockLib.Winsock sock1 
      Left            =   1200
      Top             =   2400
      _ExtentX        =   741
      _ExtentY        =   741
      _Version        =   393216
   End
   Begin MSWinsockLib.Winsock sock2 
      Left            =   1920
      Top             =   2400
      _ExtentX        =   741
      _ExtentY        =   741
      _Version        =   393216
   End
End
Attribute VB_Name = "frmMain"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Dim bConnected As Boolean
Dim bShow As Boolean
Dim bTW As Boolean
Dim connh As String
Dim user1 As String
Dim user2 As String

Private Sub Form_Load()
On Error GoTo Err_Handler
    bConnected = False
    If Command = "" Then
        MsgBox "Syntax: RLoginDoor.exe /c{handle} /h{hostname} /p{port} /u1{username1} /u2{username2} [/show] [/TW]" & vbCrLf & vbCrLf & "Please pass parameters in this order!!" & vbCrLf & vbCrLf & "Example: RLoginDoor.exe /c123 /h127.0.0.1 /p513 /u1myname /u2myserver /TW", vbCritical, "Command Line Syntax Incorrect"
        
        Unload Me
        End
    End If
    
    'Syntax: /c{handle} /h{hostname} /p{port} /u1{username1} /u2{username2} [/show] [/TW]
    Dim a() As String
    a = Split(Command, "/")
    Dim rhost As String
    connh = Trim(Right(a(1), Len(a(1)) - 1))
    rhost = Trim(Right(a(2), Len(a(2)) - 1))
    rport = Trim(Right(a(3), Len(a(3)) - 1))
    user1 = Trim(Right(a(4), Len(a(4)) - 2))
    user2 = Trim(Right(a(5), Len(a(5)) - 2))
    
    Me.Caption = "RLoginDoor - conn_id: " & connh & " - user: " & user1
    
    If InStr(1, Command, "/show") = 0 Then Me.Hide
    If InStr(1, Command, "/TW") = 0 Then bTW = False Else bTW = True
    
    sock1.Accept connh
    sock1.SendData vbCrLf & vbCrLf & "Please Wait, Connecting via RLoginDoor..."
    sock2.Connect rhost, rport
    
    Timer1.Enabled = True
    Text1.Text = Text1.Text & "X: Connecting to server..." & vbCrLf
    
Exit Sub

Err_Handler:
    MsgBox Err.Description, vbCritical, "Error #" & Err.Number & " - Event: Form_Load()"
End Sub

Private Sub sock2_Connect()
On Error GoTo Err_Handler
    If sock2.State = sckConnected Then
        Timer1.Enabled = False
        Text1.Text = "X: Connected, sending username.." & vbCrLf
        sock2.SendData vbNullChar
        sock2.SendData user1 & vbNullChar
        sock2.SendData user2 & vbNullChar
        sock2.SendData "whatever" & vbNullChar
        bConnected = True
        Text1.Text = "X: Connected." & vbCrLf
        If bTW = True Then sock2.SendData "A"
    End If
    
Exit Sub

Err_Handler:
    MsgBox Err.Description, vbCritical, "Error #" & Err.Number & " - Event: sock2_Connect()"
End Sub

Private Sub sock1_DataArrival(ByVal bytesTotal As Long)
On Error GoTo Err_Handler
    If bConnected = True Then
        Dim strData As String
        sock1.GetData strData, vbString
        
        Text1.Text = "From Client: " & vbCrLf & strData
        
        sock2.SendData strData
    End If

Exit Sub

Err_Handler:
    MsgBox Err.Description, vbCritical, "Error #" & Err.Number & " - Event: sock1_DataArrival()"
End Sub

Private Sub sock2_DataArrival(ByVal bytesTotal As Long)
On Error GoTo Err_Handler
    If bConnected = True Then
        Dim strData As String
        sock2.GetData strData, vbString
        Text1.Text = "From Server: " & vbCrLf & strData
        
        If bTW = True Then
            If InStr(1, strData, "GAME 1 - RLoginDoor") > 0 Then
                If sock2.State = sckConnected Then sock2.SendData "Q"
            Else
                If sock1.State = sckConnected Then sock1.SendData strData
            End If
        Else
            If sock1.State = sckConnected Then sock1.SendData strData
        End If
    End If
Exit Sub

Err_Handler:
    MsgBox Err.Description, vbCritical, "Error #" & Err.Number & " - Event: sock2_DataArrival()"
End Sub

Private Sub sock1_Close()
On Error GoTo Err_Handler
    bConnected = False
    sock2.Close
    'MsgBox "Client Connection Terminated, Quitting..."
    Unload Me
    End

Exit Sub

Err_Handler:
    MsgBox Err.Description, vbCritical, "Error #" & Err.Number & " - Event: sock1_Close()"
End Sub

Private Sub sock2_Close()
On Error GoTo Err_Handler
    bConnected = False
    'MsgBox "Server Connection Terminated, Quitting..."
    If sock1.State = sckConnected Then sock1.SendData "Returning from RLoginDoor..."
    Unload Me
    End

Exit Sub

Err_Handler:
    MsgBox Err.Description, vbCritical, "Error #" & Err.Number & " - Event: sock2_Close()"
End Sub

Private Sub Timer1_Timer()
On Error GoTo Err_Handler
    Timer1.Enabled = False
    sock1.SendData vbCrLf & vbCrLf & "Timeout connecting to RLogin server..."
    Timer2.Enabled = True

Exit Sub

Err_Handler:
    MsgBox Err.Description, vbCritical, "Error #" & Err.Number & " - Event: Timer1_Timer()"
End Sub

Private Sub Timer2_Timer()
On Error GoTo Err_Handler
    Unload Me
    End

Exit Sub

Err_Handler:
    MsgBox Err.Description, vbCritical, "Error #" & Err.Number & " - Event: Timer2_Timer()"
End Sub
