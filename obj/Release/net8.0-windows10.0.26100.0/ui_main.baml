   M S B A M L   `   `   `  ���� D  @xrToolkit, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null%clr-namespace:xrToolkit	xrToolkit      xrToolkit.ui_main   W SPresentationCore, Version=8.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35\ XPresentationFramework, Version=8.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35e aSystem.Windows.Controls.Ribbon, Version=8.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089R NWindowsBase, Version=8.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35^ ZWindowsFormsIntegration, Version=8.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35H 9http://schemas.microsoft.com/winfx/2006/xaml/presentation      R NSystem.Xaml, Version=8.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089:x,http://schemas.microsoft.com/winfx/2006/xaml     @d2http://schemas.microsoft.com/expression/blend/2008     Jmc;http://schemas.openxmlformats.org/markup-compatibility/2006     )localclr-namespace:xrToolkit     -     �Name$  ui_main_xrtoolkit�� � Title$ xrToolkit v1.0��$	��521��$	��500�� � Icon$ /icon_toolkit.png�� � WindowStartupLocation$ CenterScreen=�.��� .+�c� -    c�Name$ toolbar_toolkit��$��32��$	��Top=����	#FFEDEDED.@��� $��Selected workspace:���� -    ��Name$ combo_workspaces��$	��120��$��12�� �� SelectedIndex$ 0�� � UseLayoutRounding$ False�� � Cursor$
 Hand�����	#FF8E8E8E�� -   	 ��Name$
	 tabs��$��	0,32,0,-1q�.@��� -   
 ��Name$
 tab_home��$
��Home��.��� �� -   $
 tab_workspaces��$��Center=�$��20��$��
Workspaces��$	��Top=�$��75��$��0,-1,0,0q�.��� .+��� -    ��Name$ list_workspaces��$��
20,62,0,87q�$
��Left=�$	��150���� $��
Workspaces��$
��Left=�$��	20,31,0,0q�$	��Top=��� $��Gamedata path��$
��Left=�$��
191,62,0,0q�$	��Top=��� $��Rawdata path��$
��Left=�$��191,159,0,0q�$	��Top=��� -    ��Name$ input_workspace_rawdata��$��191,190,80,0q�$	��Top=�$��24���� -	   $ input_workspace_gamedata��$��191,93,80,0q�$	��Top=�$��24���� -
    ��Name$ btn_workspace_gamedata��$	��Set��$��	0,93,29,0q�$	��Top=� J� RenderTransformOrigin$ -0.05,-0.349&�$��24��$��Right=�$��46��
�������$
 Hand���� -   $ btn_workspace_rawdata��$	��Set��$��
0,190,29,0q�$	��Top=�$ -0.05,-0.349&�$��24��$��Right=�$��46��
�������$
 Hand���� -   $ btn_save_workspace��$
��Save��$��271,265,115,0q�$��35��$	��Top=�${�False�����	#FF9E9E9E$
 Hand���� -   $ btn_create_workspace��$��Create��$
��Left=�$��	23,0,0,62q�$��54��$��20��$��Bottom=����	#FF9E9E9E$
 Hand���� -   $ delete_workspace��$��Delete��$
��Left=�$��	82,0,0,62q�$��49��$��20��$��Bottom=����	#FF9E9E9E$
 Hand���� -   $
 	tab_files��$��Center=�$��20��$��Files��$	��Top=�$��36��$��0,-1,0,0q�.��� $	��447��$��	-2,0,-2,0q�.+��� -   $	 subtab_files��$��	0,0,-2,-2q�.@��� -   $
 tab_gamedata��$
��Left=�$��20��$��Gamedata unpacker��$	��Top=�$	��123��.���  � ColumnDefinitions �� .+��� $��Database files input path��$
��Left=�$��	33,28,0,0q�$	��Top=��� $ ��Unpacked files output path��$
��Left=�$��
33,105,0,0q�$	��Top=��� -   $ input_db_input��$��
38,60,99,0q�$	��Top=�$��22���� -   $ input_db_output��$��38,133,99,0q�$	��Top=�$��23���� -   $ btn_input_db��$	��Set��$��	0,60,48,0q�$	��Top=�$��22��$
 Hand��
�������$��Right=�$��46���� -   $ btn_output_db��$	��Set��$��
0,133,48,0q�$	��Top=�$��23��$
 Hand��
�������$��Right=�$��46���� $��Settings��$
��Left=�$��
40,183,0,0q�$	��Top=�$ 0.532,-1&�	� -    	�Name$ rdn_db_game_cscop��$��CS/CoP��$
��Left=�$��
51,214,0,0q�$	��Top=� 	� 	GroupName$ game_unpack��$
 Hand�� d� 	IsChecked$
 TrueY�	� -   $ rdn_db_game_socww��$��SoC (WW)��$
��Left=�$��
51,234,0,0q�$	��Top=�$ game_unpack��$
 Hand��	� -   $ rdn_db_game_socru��$��SoC (Ru)��$
��Left=�$��
51,254,0,0q�$	��Top=�$ game_unpack��$
 Hand���� -   $ btn_unpack_db��$��Unpack��$��	0,0,62,36q�$��35��$��Bottom=�$��Right=�$	��132�����	#FF9E9E9E$
 Hand���� -   $ 	status_db��$��184,196,48,98q� �� TextWrapping$
 Wrap=�${�False��$ False���� $��Gamedata packer��.��� �� -   $
 tab_converter��$��
Converters��$��
-1,-2,-3,0q�.��� .+��� $��-3,-3,-3,-3q�.@��� -   $
 	ogfobject��$��OGF to OBJECT��.��� $	��354��$��	-2,0,-2,0q�.+��� $��
Input path��$
��Left=�$��	30,20,0,0q�$	��Top=��� -   $ input_ogfobj_input��$��
30,52,98,0q�$	��Top=�$��24�� J� 	AllowDrop$ False���� $��Output path��$
��Left=�$��	30,84,0,0q�$	��Top=��� -   $ input_ogfobj_output��$��30,114,98,0q�$	��Top=�$��24��$ False���� -   $ btn_ogfobj_convert��$��Convert��$��148,0,164,33q�$��45��$��Bottom=����	#FFDDDDDD���	#FF9E9E9E$
 Hand���� -    $ btn_input_ogfobj��$	��Set��$��	0,52,46,0q�$	��Top=�$ -0.05,-0.349&�$��24��$��Right=�$��46��
�������$
 Hand���� -!   $ btn_output_ogfobj��$	��Set��$��
0,114,46,0q�$	��Top=�$ 0.05,-0.599&�$��24��$��Right=�$��46��
�������$
 Hand���� -"   $ status_ogfobj��$��30,180,46,106q�$
 Wrap=�${�False���� -#    ��Name$ check_ogfobj_autostore��$$��Store in rawdata automatically��$
��Left=�$��
30,148,0,0q�$	��Top=�$ 0.472,1.062&�$
 Hand���� -$   $
 omfskls��$��OMF to SKLS��.��� $	��354��$��	-2,0,-2,0q�.+��� $��
Input path��$
��Left=�$��	30,20,0,0q�$	��Top=��� -%   $ input_omfskls_input��$��
30,52,98,0q�$	��Top=�$��24��$ False���� $��Output path��$
��Left=�$��	30,84,0,0q�$	��Top=��� -&   $ input_omfskls_output��$��30,114,98,0q�$	��Top=�$��24��$ False���� -'   $ btn_omfskls_convert��$��Convert��$��148,0,164,33q�$��45��$��Bottom=����	#FFDDDDDD���	#FF9E9E9E$
 Hand���� -(   $ btn_input_omfskls��$	��Set��$��	0,52,46,0q�$	��Top=�$ -0.05,-0.349&�$��24��$��Right=�$��46��
�������$
 Hand���� -)   $ btn_output_omfskls��$	��Set��$��
0,114,46,0q�$	��Top=�$ 0.05,-0.599&�$��24��$��Right=�$��46��
�������$
 Hand���� -*   $ status_omfskls��$��30,180,46,106q�$
 Wrap=�${�False���� -+   $ check_omfskls_autostore��$$��Store in rawdata automatically��$
��Left=�$��
30,148,0,0q�$	��Top=�$ 0.472,1.062&�$
 Hand���� -,   $
 
tab_ddstga��$��Center=�$��20��$��
DDS to TGA��$	��Top=�$��76��$��0,-1,0,0q�.��� $	��354��$��	-2,0,-2,0q�.+��� $��
Input path��$
��Left=�$��	30,20,0,0q�$	��Top=��� --   $ input_ddstga_input��$��
30,52,98,0q�$	��Top=�$��24��$ False���� $��Output path��$
��Left=�$��	30,84,0,0q�$	��Top=��� -.   $ input_ddstga_output��$��30,114,98,0q�$	��Top=�$��24��$ False���� -/   $ btn_ddstga_convert��$��Convert��$��148,0,164,33q�$��45��$��Bottom=����	#FFDDDDDD���	#FF9E9E9E$
 Hand���� -0   $ btn_input_ddstga��$	��Set��$��	0,52,46,0q�$	��Top=�$ -0.05,-0.349&�$��24��$��Right=�$��46��
�������$
 Hand���� -1   $ btn_output_ddstga��$	��Set��$��
0,114,46,0q�$	��Top=�$ 0.05,-0.599&�$��24��$��Right=�$��46��
�������$
 Hand���� -2   $ status_ddstga��$��30,180,46,106q�$
 Wrap=�${�False���� -3   $ check_ddstga_autostore��$$��Store in rawdata automatically��$
��Left=�$��
30,148,0,0q�$	��Top=�$ 0.472,1.062&�$
 Hand���� -4   $
 
tab_oggwav��$��Center=�$��20��$��
OGG to WAV��$	��Top=�$��84��$��0,-1,0,0q�.��� $��	-2,0,-2,0q�$	��354��.+��� $��
Input path��$
��Left=�$��	30,20,0,0q�$	��Top=��� -5   $ input_oggwav_input��$��
30,52,98,0q�$	��Top=�$��24��$ False���� $��Output path��$
��Left=�$��	30,84,0,0q�$	��Top=��� -6   $ input_oggwav_output��$��30,114,98,0q�$	��Top=�$��24��$ False���� -7   $ btn_oggwav_convert��$��Convert��$��148,0,164,33q�$��45��$��Bottom=����	#FFDDDDDD���	#FF9E9E9E$
 Hand���� -8   $ btn_input_oggwav��$	��Set��$��	0,52,46,0q�$	��Top=�$ -0.05,-0.349&�$��24��$��Right=�$��46��
�������$
 Hand���� -9   $ btn_output_oggwav��$	��Set��$��
0,114,46,0q�$	��Top=�$ 0.05,-0.599&�$��24��$��Right=�$��46��
�������$
 Hand���� -:   $ status_oggwav��$��30,180,46,106q�$
 Wrap=�${�False���� -;   $ check_oggwav_autostore��$$��Store in rawdata automatically��$
��Left=�$��
30,148,0,0q�$	��Top=�$ 0.472,1.062&�$
 Hand���� -<   $
 tab_textures��$��Center=�$��20��$��Textures��$	��Top=�$��62��$��0,-1,0,0q�.��� $	��452��$��	-2,0,-2,0q�.+��� $��0,0,0,4q�.@��� $��Tools��.��� .+��� -=   $ btn_tool_iconeditor��$��Icon Editor
(SIE)��$��Center=�$��	0,114,0,0q�$	��Top=�$��78��$	��378�����	#FFEFEFEF$
 Hand���� ->   $ btn_tool_thmeditor��$��
THM Editor��$��Center=�$��	0,221,0,0q�$	��Top=�$��74��$	��378�����	#FFEFEFEF$
 Hand���� $��Bump Map Generator��.��� �� -?   $
 tab_mapping��$��Center=�$��20��$��Mapping��$	��Top=�$��64��$��0,-1,0,0q�.��� .+��� -@   $	 subtab_mapping��$��-2,-2,-2,-2q�.@��� $��Center=�$��20��$��Tools��$��Center=�$��54��.��� .+��� -A   $ btn_tool_compilelevel��$��Compile level
(SkyLoader)��$��Center=�$��	0,112,0,0q�$	��Top=�$��78��$	��410�����	#FFEFEFEF$
 Hand���� -B   $
 tab_map��$��Level decompiler��.���  �� .+��� $��Level name:��$
��Left=�$��	40,32,0,0q�$	��Top=��� -C   $ input_map_name��$��	40,58,0,0q�$	��Top=�$��26��$
��Left=�$	��194��$ False���� -D   $ btn_decompile_map��$��	Decompile��$��	0,0,39,35q�$ -0.746,0.606&�$��Right=�$	��141��$��41��$��Bottom=����	#FF9E9E9E$
 Hand���� -E   $ status_level��$��39,116,39,113q�$
 Wrap=�${�False���� $��Spawn decompiler��.��� �� -F   $
 
tab_sounds��$��Center=�$��20��$��Sounds��$��Center=�$��54��.��� $	��448��$��	-2,0,-2,0q�.+��� .@��� $��Tools��.��� .+��� -G   $ btn_tool_oggeditor��$#��OGG Comments Editor
(SAVandT)��$
��Left=�$��Center=�$	��104��$	��320�����	#FFEFEFEF$
 Hand��$��73,0,0,0q��� -H   $
 tab_animations��$��Center=�$��20��$��
Animations��$	��Top=�$��74��$��0,-1,0,0q�.��� $	��448��$��	-2,0,-2,0q�.+��� ���	#FFACACAC��Z� .@��� $��Tools��.��� .+��� -I   $ btn_tool_omfeditor��$!��Animation File Editor
(OMF)��$��Center=�$��	0,138,0,0q�$	��Top=�$��98��$	��320�����	#FFEFEFEF$
 Hand��