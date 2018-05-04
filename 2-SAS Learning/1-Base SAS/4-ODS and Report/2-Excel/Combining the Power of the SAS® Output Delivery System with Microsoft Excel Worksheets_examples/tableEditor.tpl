
proc template;
   define tagset Tagsets.Tableeditor;
      mvar sysver;
      define event initialize;
      do /if $options["BANNER_COLOR_EVEN"];
            set $banner_even $options["BANNER_COLOR_EVEN" ];

         else;
            unset $banner_even;
         done;

         do /if $options["BANNER_COLOR_ODD"];
            set $banner_odd $options["BANNER_COLOR_ODD" ];

         else;
            unset $banner_odd;
         done;

         do /if $options["FBANNER_COLOR_EVEN"];
            set $fbanner_even $options["FBANNER_COLOR_EVEN" ];

         else;
            unset $fbanner_even;
         done;

         do /if $options["FBANNER_COLOR_ODD"];
            set $fbanner_odd $options["FBANNER_COLOR_ODD" ];

         else;
            unset $fbanner_odd;
         done;

         do /if $options["COL_COLOR_ODD"];
            set $col_odd $options["COL_COLOR_ODD" ];

         else;
            unset $col_odd;
         done;

         do /if $options["COL_COLOR_EVEN"];
            set $col_even $options["COL_COLOR_EVEN" ];

         else;
            unset $col_even;
         done;

         do /if $options["HEADER_BCOLOR"];
            set $header_bcolor $options["HEADER_BCOLOR" ];

         else;
            unset $header_bcolor;
         done;

         do /if cmp( $options["OVERRIDE"], "yes");
            set $override "yes";

         else;
            unset $override;
         done;

         do /if cmp( $options["FROZEN_HEADERS"], "yes");
            set $frozen_headers "yes";

         else;
            unset $frozen_headers;
         done;

         do /if $options["FROZEN_ROWHEADERS"];
            set $frozen_rowheaders $options["FROZEN_ROWHEADERS" ];

         else;
            unset $frozen_rowheaders;
         done;

         do /if $options["HIGHLIGHT_COLOR"];
            set $highlight_color $options["HIGHLIGHT_COLOR" ];

         else;
            unset $highlight_color;
         done;

         do /if $options["GRIDLINES"];
            set $borders $options["GRIDLINES" ];

         else;
            unset $borders;
         done;

         do /if $options["GRIDLINE_COLOR"];
            set $gridline_color $options["GRIDLINE_COLOR" ];

         else;
            unset $gridline_color;
         done;

         do /if $options["BACKGROUND_IMAGE"];
            set $background_image $options["BACKGROUND_IMAGE" ];

         else;
            unset $background_image;
         done;

         do /if cmp( $options["LOAD_MSG"], "yes");
            set $loadmsg $options["LOAD_MSG" ];

         else;
            unset $loadmsg;
         done;

         do /if $options["LOAD_IMG"];
            set $loadimg $options["LOAD_IMG" ];

         else;
            unset $loadimg;
         done;

         do /if $options["OPEN_EXCEL"];
            set $open_excel $options["OPEN_EXCEL" ];

         else;
            unset $open_excel;
         done;


         do /if $options["SORT"];
            set $sort $options["SORT" ];

         else;
            unset $sort;
         done;

         do /if $options["AUTOFILTER"];
            set $autofilter $options["AUTOFILTER" ];

         else;
            unset $autofilter;
         done;

         do /if $options["AUTOFILTER_WIDTH"];
            set $autofilter_width $options["AUTOFILTER_WIDTH" ];

         else;
            unset $autofilter_width;
         done;

         do /if $options["AUTOFILTER_ENDCOL"];
            set $autofilter_endcol $options["AUTOFILTER_ENDCOL" ];

         else;
            unset $autofilter_endcol;
         done;

         do /if $options["AUTOFILTER_TABLE"];
            set $autofilter_table $options["AUTOFILTER_TABLE" ];

         else;
            unset $autofilter_table;
         done;

         do /if $options["DESCRIBE"];
            set $describe $options["DESCRIBE" ];

         else;
            unset $describe;
         done;

         do /if $options["SORT_ARROW_COLOR"];
            set $arrowcolor $options["SORT_ARROW_COLOR" ];

         else;
            unset $arrowcolor;
         done;

         do /if $options["SORT_IMAGE"];
            set $sort_image $options["SORT_IMAGE" ];

         else;
            unset $sort_image;
         done;

         do /if $options["SORT_UNDERLINE"];
            set $sort_underline $options["SORT_UNDERLINE" ];

         else;
            unset $sort_underline;
         done;

         do /if $options["ZOOM_TABLE"];
            set $ztable1 $options["ZOOM_TABLE" ];

         else;
            unset $ztable1;
         done;

         do /if $options["WINDOW_TITLE"];
            set $wtitle $options["WINDOW_TITLE" ];

         else;
            unset $wtitle;
         done;

         do /if $options["INCLUDE"];
            set $include $options["INCLUDE" ];

         else;
            unset $include;
         done;


         do /if $options["FIT2PAGE"];
            set $fit2page $options["FIT2PAGE" ];

         else;
            unset $fit2page;
         done;


         do /if $options["FROZEN_HEADERS_ALL"];
            set $frozen_headers_all $options["FROZEN_HEADERS_ALL" ];

         else;
            unset $frozen_headers_all;
         done;

         do /if $options["PAGEHEIGHT"];
            set $pageheight $options["PAGEHEIGHT" ];

         else;
            unset $pageheight;
         done;

         do /if $options["PAGEWIDTH"];
            set $pagewidth $options["PAGEWIDTH" ];

         else;
            unset $pagewidth;
         done;

         do /if $options["SHEET_NAME"];
            set $sheet_name $options["SHEET_NAME" ];

         else;
            unset $sheet_name;
         done;

         do /if $options["ALERT_TEXT"];
            set $alert_text $options["ALERT_TEXT" ];

         else;
            unset $alert_text;
         done;

         do /if $options["WINDOW_STATUS"];
            set $window_status $options["WINDOW_STATUS" ];

         else;
            unset $window_status;
         done;


         do /if $options["POWERPOINT_SLIDES"];
            set $slides $options["POWERPOINT_SLIDES" ];

         else;
            unset $slides;
         done;

         do /if $options["POWERPOINT_MASTER"];
            set $ppmaster $options["POWERPOINT_MASTER" ];

         else;
            unset $ppmaster;
         done;

         do /if $options["POWERPOINT_TEMPLATE"];
            set $powerpoint_template $options["POWERPOINT_TEMPLATE" ];

         else;
            unset $powerpoint_template;
         done;

         do /if $options["POWERPOINT_SAVEAS"];
            set $powerpoint_saveas $options["POWERPOINT_SAVEAS" ];

         else;
            unset $powerpoint_saveas;
         done;

         do /if $options["POWERPOINT_RUN"];
            set $pprun $options["POWERPOINT_RUN" ];

         else;
            unset $pprun;
         done;

        do /if $options["FILTER_COLS"];
            set $filter_cols $options["FILTER_COLS" ];

         else;
            unset $filter_cols;
         done;

         do /if $options["HIDE_COLS"];
            set $hide_cols $options["HIDE_COLS" ];

         else;
            unset $hide_cols;
         done;

         do /if $options["WEB_TABS"];
            set $web_tabs $options["WEB_TABS" ];

         else;
            unset $web_tabs;
         done;

         do /if $options["WEB_TABS_JUST"];
            set $web_tabs_just $options["WEB_TABS_JUST" ];

         else;
            unset $web_tabs_just;
         done;

         do /if $options["WEB_TABS_FGCOLOR"];
            set $web_tabs_fgcolor $options["WEB_TABS_FGCOLOR" ];

         else;
            unset $web_tabs_fgcolor;
         done;

         do /if $options["WEB_TABS_BGCOLOR"];
            set $web_tabs_bgcolor $options["WEB_TABS_BGCOLOR" ];

         else;
            unset $web_tab_bgcolor;
         done;

         do /if $options["WINDOW_SIZE"];
            set $window_size $options["WINDOW_SIZE" ];

         else;
            unset $window_size;
         done;

         do /if $options["HEADER_VERTICAL"];
            set $header_vertical $options["HEADER_VERTICAL" ];

         else;
            unset $header_vertical;
         done;

         do /if $options["HEADER_DISPLAY"];
            set $header_display $options["HEADER_DISPLAY" ];

         else;
            unset $header_display;
         done;

         do /if $options["AUTO_EXCEL"];
            set $auto_excel $options["AUTO_EXCEL" ];

         else;
            unset $auto_excel;
         done;

         do /if $options["AUTO_POWERPOINT"];
            set $auto_powerpoint $options["AUTO_POWERPOINT" ];

         else;
            unset $auto_powerpoint;
         done;

         do / if $options["BUTTON_TEXT"];
             set $button_text $options["BUTTON_TEXT"];
         else;
             unset $button_text;
         done;

         do / if $options["FORMAT_EMAIL"];
             set $format_email $options["FORMAT_EMAIL"];
         else;
             unset $format_email;
         done;

         do / if $options["PRINT_HEADER"];
             set $print_header $options["PRINT_HEADER"];
         else;
             unset $printer_header;
         done;

         do / if $options["PRINT_FOOTER"];
             set $print_footer $options["PRINT_FOOTER"];
         else;
             unset $printer_footer;
         done;

         do / if $options["LIST_PIVOT_FORMATS"];
             set $list_pivot_formats $options["LIST_PIVOT_FORMATS"];
         else;
             unset $list_pivot_formats;
         done;

         do / if $options["OUTPUT_TYPE"];
             set $output_type $options["OUTPUT_TYPE"];
         else;
             unset $output_type;
         done;

         putlog "V2.75  4/1/2014";

         trigger valid_TE_options;

         trigger check_valid_TE_options;

         trigger list_TE_options / if cmp($options["DOC"],"help");

         trigger set_just_lookup;


      end;

      define event excel_options;

        do /if $options["WORKSHEET_LOCATION"];
            set $worksheet_location $options["WORKSHEET_LOCATION"];

         else;
            unset $worksheet_location;
         done;

         do /if $options["SHEET_INTERVAL"];
            set $sheet_interval $options["SHEET_INTERVAL"];

         else;
            unset $sheet_interval;
         done;


         do /if $options["EXCEL_SHEET_PROMPT"];
            set $excel_sheet_prompt $options["EXCEL_SHEET_PROMPT" ];

         else;
            unset $excel_sheet_prompt;
         done;


         do /if $options["EXCEL_SAVE_PROMPT"];
            set $excel_save_prompt $options["EXCEL_SAVE_PROMPT" ];

         else;
            unset $excel_save_prompt;
         done;

         do /if $options["OPEN_EXCEL"];
            set $open_excel $options["OPEN_EXCEL" ];

         else;
            unset $open_excel;
         done;


         do /if $options["EXCEL_OPEN"];
            set $excel_open $options["EXCEL_OPEN" ];

         else;
            unset $excel_open;
         done;

         do /if $options["EXCEL_SAVE_DIALOG"];
            set $excel_save_dialog $options["EXCEL_SAVE_DIALOG" ];

         else;
            unset $excel_save_dialog;
         done;

         do /if $options["EXCEL_AUTOFILTER"];
            set $excel_autofilter $options["EXCEL_AUTOFILTER" ];

         else;
            unset $excel_autofilter;
         done;

         do /if $options["EXCEL_ORIENTATION"];
            set $excel_orientation $options["EXCEL_ORIENTATION" ];

         else;
            unset $excel_orientation;
         done;

         do /if $options["EXCEL_TABLE_MOVE"];
            set $excel_table_move $options["EXCEL_TABLE_MOVE" ];

         else;
            unset $excel_table_move;
         done;

         do /if $options["EXCEL_FROZEN_HEADERS"];
            set $excel_frozen_headers $options["EXCEL_FROZEN_HEADERS" ];

         else;
            unset $excel_frozen_headers;
         done;


         do /if $options["FILE_FORMAT"];
            set $file_format $options["FILE_FORMAT" ];

         else;
            unset $file_format;
         done;

         do /if $options["EXCEL_ZOOM"];
            set $excel_zoom $options["EXCEL_ZOOM" ];

         else;
            unset $excel_zoom;
         done;

         do /if $options["MACRO"];
            set $macro $options["MACRO" ];

         else;
            unset $macro;
         done;

         do /if $options["EXCEL_SCALE"];
            set $excel_scale $options["EXCEL_SCALE"];

         else;
            unset $excel_scale;
         done;

         do /if $options["EMBEDDED_TITLES"];
            set $switch_titles $options["EMBEDDED_TITLES" ];

         else;
            unset $switch_titles;
         done;

         do /if $options["EMBEDDED_TABLES"];
            set $switch_titles $options["EMBEDDED_TABLES" ];

         else;
            unset $switch_titles;
         done;

        do /if $options["EXCEL_DEFAULT_WIDTH"];
            set $excel_default_width $options["EXCEL_DEFAULT_WIDTH" ];

         else;
            unset $excel_default_width;
         done;

         do /if $options["EXCEL_DEFAULT_HEIGHT"];
            set $excel_default_height $options["EXCEL_DEFAULT_HEIGHT" ];

         else;
            unset $excel_default_height;
         done;

         do /if $options["QUERY_FILE"];
            set $query_file $options["QUERY_FILE" ];

         else;
            unset $query_file;
         done;

         do /if $options["QUERY_RANGE"];
            set $query_range $options["QUERY_RANGE" ];

         else;
            unset $query_range;
         done;

         do /if $options["QUERY_TARGET"];
            set $query_target $options["QUERY_TARGET" ];

         else;
            unset $query_target;
         done;

         do /if $options["UPDATE_RANGE"];
            set $update_range $options["UPDATE_RANGE" ];

         else;
            unset $update_range;
         done;

         do /if $options["UPDATE_TARGET"];
            set $update_target $options["UPDATE_TARGET" ];

         else;
            unset $update_target;
         done;

         do /if $options["UPDATE_SHEET"];
            set $update_sheet $options["UPDATE_SHEET" ];

         else;
            unset $update_sheet;
         done;


         do /if $options["SHEET_NAME"];
            set $sheet_name $options["SHEET_NAME" ];

         else;
            unset $sheet_name;
         done;

           do /if $options["PIVOTROW"];
            set $pivotrow $options["PIVOTROW" ];

         else;
            unset $pivotrow;
         done;

         do /if $options["PIVOTCOL"];
            set $pivotcol $options["PIVOTCOL" ];

         else;
            unset $pivotcol;
         done;

         do /if $options["PIVOTDATA"];
            set $pivotdata $options["PIVOTDATA" ];

         else;
            unset $pivotdata;
         done;

         do /if $options["PIVOTPAGE"];
            set $pivotpage $options["PIVOTPAGE" ];

         else;
            unset $pivotpage;
         done;

         do /if $options["PTSOURCE_RANGE"];
            set $ptsource_range $options["PTSOURCE_RANGE" ];

         else;
            unset $ptsource_range;
         done;

         do /if $options["PTDEST_RANGE"];
            set $ptdest_range $options["PTDEST_RANGE" ];

         else;
            unset $ptdest_range;
         done;


         do /if $options["AUTO_FORMAT"];
            set $auto_format $options["AUTO_FORMAT" ];

         else;
            unset $auto_format;
         done;

         do /if $options["CHART_TYPE"];
            set $chart_type compress($options["CHART_TYPE"]);

         else;
            unset $chart_type;
         done;


         do /if $options["CHART_SOURCE"];
            set $chart_source $options["CHART_SOURCE" ];

         else;
            unset $chart_source;
         done;

       do /if $options["NUMBER_FORMAT"];
            set $number_format $options["NUMBER_FORMAT" ];

         else;
            unset $number_format;
         done;

         do / if $options["BUTTON_TEXT"];
             set $button_text $options["BUTTON_TEXT"];
         else;
             unset $button_text;
         done;

         do / if $options["PIVOTROW_FMT"];
             set $pivotrow_fmt $options["PIVOTROW_FMT"];
         else;
             unset $pivotrow_fmt;
         done;

         do / if $options["PIVOTCOL_FMT"];
             set $pivotcol_fmt $options["PIVOTCOL_FMT"];
         else;
             unset $pivotcol_fmt;
         done;

         do / if $options["PIVOTDATA_FMT"];
             set $pivotdata_fmt $options["PIVOTDATA_FMT"];
         else;
             unset $pivotdata_fmt;
         done;

         do / if $options["PIVOTPAGE_FMT"];
             set $pivotpage_fmt $options["PIVOTPAGE_FMT"];
         else;
             unset $pivotpage_fmt;
         done;

         do / if $options["PIVOTDATA_FMT"];
             set $pivotdata_fmt $options["PIVOTDATA_FMT"];
         else;
             unset $pivotdata_fmt;
         done;

         do / if $options["PIVOTDATA_STATS"];
             set $pivotdata_stats $options["PIVOTDATA_STATS"];
         else;
             unset $pivotdata_stats;
         done;

         do / if $options["PIVOTCALC"];
             set $pivotcalc $options["PIVOTCALC"];
         else;
             unset $pivotcalc;
         done;

         do / if $options["PIVOTDATA_CAPTION"];
             set $pivotdata_caption $options["PIVOTDATA_CAPTION"];
          else;
             unset $pivotdata_caption;
         done;

         do / if $options["CHART_TITLE"];
             set $chart_title $options["CHART_TITLE"];
         else;
             unset $chart_title;
         done;

         do / if $options["CHART_XAXES_TITLE"];
             set $chart_xaxes_title $options["CHART_XAXES_TITLE"];
         else;
             unset $chart_xaxes_title;
         done;

         do / if $options["CHART_XAXES_SIZE"];
             set $chart_xaxes_size $options["CHART_XAXES_SIZE"];
         else;
             unset $chart_xaxes_size;
         done;

          do / if $options["CHART_YAXES_TITLE"];
             set $chart_yaxes_title $options["CHART_YAXES_TITLE"];
         else;
             unset $chart_yaxes_title;
         done;

          do / if $options["CHART_LOCATION"];
             set $chart_location $options["CHART_LOCATION"];
         else;
             unset $chart_location;
         done;

         do / if $options["PIVOTCHARTS"];
             set $pivotcharts $options["PIVOTCHARTS"];
         else;
             unset $pivotcharts;
         done;

         do / if $options["PIVOT_FORMAT"];
             set $pivot_format $options["PIVOT_FORMAT"];
         else;
             unset $pivot_format;
         done;

         do / if $options["CHART_AREA_COLOR"];
             set $chart_area_color $options["CHART_AREA_COLOR"];
         else;
             unset $chart_area_color;
         done;

         do / if $options["CHART_PLOTAREA_COLOR"];
             set $chart_plotarea_color $options["CHART_PLOTAREA_COLOR"];
         else;
             unset $chart_plotarea_color;
         done;

          do / if $options["LIST_CHART_TYPES"];
             set $list_chart_types $options["LIST_CHART_TYPES"];
         else;
             unset $list_chart_types;
         done;

        do / if $options["LIST_PIVOT_FORMATS"];
             set $list_pivot_formats $options["LIST_PIVOT_FORMATS"];
         else;
             unset $list_pivot_formats;
         done;


          do / if $options["UPDATE_SHEET"];
             set $update_sheet $options["UPDATE_SHEET"];
         else;
             unset $update_sheet;
         done;

         do / if $options["WORKSHEET_TEMPLATE"];
             set $worksheet_template $options["WORKSHEET_TEMPLATE"];
         else;
             unset $worksheet_template;
         done;

         do / if $options["CHART_DATALABELS"];
             set $chart_datalabels $options["CHART_DATALABELS"];
         else;
             unset $chart_datalabels;
         done;

              do / if $options["CHART_POSITION"];
             set $chart_position $options["CHART_POSITION"];
         else;
             unset $chart_position;
         done;

             do / if $options["CHART_STYLE"];
             set $chart_style $options["CHART_STYLE"];
         else;
             unset $chart_style;
         done;

              do / if $options["CHART_YAXES_ORIENTATION"];
             set $chart_yaxes_orientation $options["CHART_YAXES_ORIENTATION"];
         else;
             unset $chart_yaxes_orientation;
         done;

         do / if $options["CHART_XAXES_ORIENTATION"];
             set $chart_xaxes_orientation $options["CHART_XAXES_ORIENTATION"];
         else;
             unset $chart_xaxes_orientation;
         done;

             do / if $options["CHART_LEGEND"];
             set $chart_legend $options["CHART_LEGEND"];
         else;
             unset $chart_legend;
         done;

             do / if $options["CHART_YAXES_NUMBERFORMAT"];
             set $chart_yaxes_numberformat $options["CHART_YAXES_NUMBERFORMAT"];
         else;
             unset $chart_yaxes_numberformat;
         done;


         do / if $options["CHART_YAXES_MINSCALE"];
             set $chart_yaxes_minscale $options["CHART_YAXES_minscale"];
         else;
             unset $chart_yaxes_minscale;
         done;


         do / if $options["CHART_YAXES_MAXSCALE"];
             set $chart_yaxes_maxscale $options["CHART_YAXES_MAXSCALE"];
         else;
             unset $chart_yaxes_maxscale;
         done;

          do / if $options["CHART_LAYOUT"];
             set $chart_layout $options["CHART_LAYOUT"];
         else;
             unset $chart_layout;
         done;

          do / if $options["PIVOT_GRANDTOTAL"];
             set $pivot_grandtotal $options["PIVOT_GRANDTOTAL"];
         else;
             unset $pivot_grandtotal;
         done;

         do / if $options["ADDFIELD"];
             set $addfield $options["ADDFIELD"];
         else;
             unset $addfield;
         done;

         do / if $options["FORMAT_CONDITION"];
             set $format_condition $options["FORMAT_CONDITION"];
         else;
             unset $format_condition;
         done;

         do / if $options["EMBEDDED_TITLES"];
             set $EMBEDDED_TITLES $options["EMBEDDED_TITLES"];
         else;
             unset $embedded_titles;
         done;

         do / if $options["EMBEDDED_FOOTNOTES"];
             set $EMBEDDED_FOOTNOTES $options["EMBEDDED_FOOTNOTES"];
         else;
             unset $embedded_footnotes;
         done;

         do / if $options["DELETE_SHEETS"];
             set $delete_sheets $options["DELETE_SHEETS"];
         else;
             unset $delete_sheets;
         done;

     end;

      define event valid_TE_options;
         set $valid_options["BANNER_COLOR_EVEN" ]
               "Color code bakground of every other row";
         set $valid_options["BANNER_COLOR_ODD" ]
               "Color code background of odd rows";
         set $valid_options["FBANNER_COLOR_EVEN" ]
               "Color code foreground of even rows";
         set $valid_options["FBANNER_COLOR_ODD" ]
               "Color code foreground of even rows";
         set $valid_options["COL_COLOR_EVEN" ] "Color background even columns";
         set $valid_options["COL_COLOR_ODD" ] "Color background of odd columns";
         set $valid_options["HIGHLIGHT_COLOR" ] "Add mouseover color of row";
         set $valid_options["GRIDLINE_COLOR" ] "Modifies gridline color";
         set $valid_options["GRIDLINE" ] "Modifies the gridlines of the table";
         set $valid_options["BACKGROUND_COLOR" ] "modifies the page background color";
         set $valid_options["HEADER_BGCOLOR" ]
               "Modifies background color of headers";
         set $valid_options["HEADER_BCOLOR" ]
               "Modifies background color of headers";
         set $valid_options["HEADER_FGCOLOR" ]
               "Modifies foreground color of headers";
         set $valid_options["HEADER_SIZE" ]
               "Modifies font size  of the column headers";
         set $valid_options["HEADER_FONT" ]
               "Modifies font of the column headers";
         set $valid_options["ROWHEADER_BGCOLOR" ]
               "Modifies background color of headers";
         set $valid_options["ROWHEADER_FGCOLOR" ]
               "Modifies foreground color of headers";
         set $valid_options["ROWHEADER_SIZE" ]
               "Modifies font size of the row headers";
         set $valid_options["ROWHEADER_SIZE" ]
               "Modifies font of the row headers";
         set $valid_options["DATA_BGCOLOR" ]
               "Modifies background color of table cells";
         set $valid_options["DATA_FGCOLOR" ]
               "Modifies foreground color of table cells";
         set $valid_options["DATA_SIZE" ]
               "Modifies font size of the table cells";
         set $valid_options["DATA_FONT" ] "Modifies font of the table cells";
         set $valid_options["DATA_WEIGHT" ] "Modifies font weight of the table cells";
         set $valid_options["HIGHLIGHT_COLS" ]
               "Modifies colors of individual columns";
         set $valid_options["TITLE_BGCOLOR" ]
               "Modifies background color of titles";
         set $valid_options["TITLE_FGCOLOR" ]
               "Modifies foreground color of titles";
         set $valid_options["TITLE_SIZE" ] "Modifies font size of titles";
         set $valid_options["TITLE_STYLE" ] "Modifies style of titles";
         set $valid_options["FONTFAMILY" ] "overrides all fonts in the document with the one specified";
         set $valid_options["ALIGN_COLS" ] "sets the alignment of columns. Each column is separated by a comma";
         set $valid_options["STYLE_SWITCH" ]
               "Dynamically switch styles using CSS files";
         set $valid_options["SCROLLBAR_COLOR" ]
               "Modifies the color of the scroll bar";
         set $valid_options["IMAGE_PATH" ] "Adds images to the page";
         set $valid_options["IMAGE_JUST" ]
               "Modifies the justification of the image";
         set $valid_options["BACKGROUND_IMAGE" ]
               "Add an image to the background of the page";
         set $valid_options["CAPTION_TEXT" ] "Provides text for the caption";
         set $valid_options["CAPTION_BACKGROUND" ]
               "Modifies background color of captions";
         set $valid_options["CAPTION_FGCOLOR" ]
               "Modifies foreground color of captions";
         set $valid_options["CAPTION_SIZE" ]
               "Modifies font size of the caption";
         set $valid_options["CAPTION_STYLE" ]
               "Modifies font style of the caption";
          set $valid_options["BUTTON_TEXT" ]
               "Modifies the text of the export button when Excel options are added";
         set $valid_options["CAPTION_IMAGE" ] "Adds image as the caption";
         set $valid_options["FROZEN_HEADERS" ]
               "Freezes or locks column headers in place. Can be used in conjunction with the Pageheight option";
         set $valid_options["FROZEN_HEADERS_ALL" ]
               "Freezes or locks column headers in place for all tables in I.E. Should be used in conjunction with the Pageheight option";
         set $valid_options["FROZEN_ROWHEADERS" ]
               "Freezes columns by by locking them. Can be used in conjunction with the Pagewidth option";
         set $valid_options["PAGEHEIGHT" ]
               "Adds vertical scroll bars to the table when page height is reached";
         set $valid_options["PAGEWIDTH" ]
               "Adds horizontal scroll bars to the table when page width is reached";
         set $valid_options["SORT" ] "Sort data by clicking on column headers";
         set $valid_options["SORT_UNDERLINE" ]
               "Adds underlines to columns that can be sorted";
         set $valid_options["SORT_IMAGE" ]
               "Adds images to columns that can be sorted";
         set $valid_options["SORT_ARROW_COLOR" ]
               "Modifies colors of up and down arrows";
         set $valid_options["SORT_FLYOVER"] "Provides flyover text with column sorted";
         set $valid_options["EXCLUDE_SUMMARY"] "Removes summaries from the sort";
         set $valid_options["DESCRIBE" ]
               "visually displays the data type of the columns";
         set $valid_options["DATA_TYPE" ]
               "Defines data type of columns provided for the sort";
         set $valid_options["EXCLUDE_SUMMARY" ]
               "Excludes the summary from the sort";
         set $valid_options["AUTOFILTER" ] "Filters columns of the table";
         set $valid_options["AUTOFILTER_TABLE" ]
               "Apply filters to specific tables";
         set $valid_options["AUTOFILTER_ENDCOL" ]
               "Ending column to apply filters";
         set $valid_options["AUTOFILTER_WIDTH" ]
               "Specify width for the filter width";
         set $valid_options["FILTER_COLS" ]
               "Apply filters to specific columns";
         set $valid_options["PANELCOLS" ]
               "Allows multiple columns of tables or graphs per page";
          set $valid_options["PANELROWS" ]
               "Allows multiple rows of tables or graphs per page";
         set $valid_options["ZOOM" ] "Applies zoom to document";
         set $valid_options["ZOOM_TABLE" ]
               "Applies zoom to each table individually by specifying zoom value separated by a comma";
         set $valid_options["ZOOM_TOGGLE" ]
               "Add dynamic selection list on page to select zoom";
         set $valid_options["WEB_TABS" ]
               "Add web tabs similiar to sheet names of Excel";
         set $valid_options["WEB_TABS_JUST" ]
               "sets the justification for the web tabs";
         set $valid_options["REORDER_COLS" ]
               "Dynamically reorder columns by dragging and dropping columns";
         set $valid_options["HIDE_COLS" ]
               "Provides the ability to double click on columns and remove";
         set $valid_options["DRAG" ]
               "Ability to drag and drop items of the page";
         set $valid_options["DESIGN_MODE" ]
               "Provide the ability to edit items on the page";
         set $valid_options["WINDOW_TITLE" ] "Adds title to the body file";
         set $valid_options["WINDOW_STATUS" ] "Adds text to the status bar";
         set $valid_options["ALERT_TEXT" ]
               "Applies a dialog box with text when window loaded";
         set $valid_options["INCLUDE" ]
               "Add files of various format into the file";
         set $valid_options["WINDOW_SIZE" ]
               "Provides the ability to modify window size";
         set $valid_options["FIT2PAGE_MSG" ]
               "Generates dialog box with the scaling of the output when the F
IT2PAGE options would specified";
         set $valid_options["LOAD_IMG" ]
               "Specifies an image for the page load";
         set $valid_options["LOAD_MSG" ] "Specifies text for the page load";
         set $valid_options["HEADER_DISPLAY" ]
               "Provides the ability to remove column headers for the table";
         set $valid_options["HEADER_VERTICAL" ]
               "Modifies the orientation of the column headers";
             set $valid_options["RADIO" ]
               "Adds radio boxes to a column";
             set $valid_options["RADIO_CHECKED" ]
               "Adds checks to the radio boxes based on the value";
         set $valid_options["ORIENTATION" ]
               "Modifies the orientation of the document";
         set $valid_options["PRINT_HEADER" ]
               "Adds headers for for the printed document";
         set $valid_options["PRINT_FOOTER" ]
               "Adds footers to the printed document";
         set $valid_options["LEFT_MARGIN" ] "Adds left margin to the file";
         set $valid_options["RIGHT_MARGIN" ] "Adds right margin to the file";
         set $valid_options["TOP_MARGIN" ] "Adds top margin to the file";
         set $valid_options["BOTTOM_MARGIN" ] "Adds bottom margin to the file";
         set $valid_options["FIT2PAGE" ] "Scales output to fit printed page";
         set $valid_options["PRINT_ZOOM" ]
               "Scales the printed output based on the value given";
         set $valid_options["PAGEBREAK_TOGGLE" ]
               "Adds check box to turn page breaks on or off";
         set $valid_options["PRINT_DIALOG" ]
               "Adds print and other tool bar options to the page";
         set $valid_options["CLOSED_IMAGE" ]
               "Specifies image for the for the cloded items TOC";
         set $valid_options["LEAF_IMAGE" ]
               "Specifies image for the leaf in the TOC";
         set $valid_options["SHEET_NAME" ]
               "Provides a sheet name when table(s) exported";
         set $valid_options["OPEN_EXCEL"]
               "Specifies whether the Excel file is opened";
         set $valid_options["EXCEL_OPEN"]
               "Specifies whether the Excel file is opened";
         set $valid_options["QUIT" ]
               "Closes the application after writing to it";
         set $valid_options["EXCEL_SHEET_PROMPT" ]
               "Generates a prompt for the sheet name";
         set $valid_options["EXCEL_SAVE_PROMPT" ]
               "Generates a prompt for path to save file";
             set $valid_options["SAVEAS" ]
               "Allows a file to be saved and can be specified with the DEFAULT_FILE= option to
 define a default file";
          set $valid_options["DEFAULT_FILE" ]
               " Specifies the name of a default file when used with the SAVEAS= option";
         set $valid_options["EXCEL_SAVE_DIALOG" ]
               "Adds a dialog box to save Excel file";
         set $valid_options["EXCEL_SAVE_FILE" ]
               "Specifies the location of the and name of the saved file";
         set $valid_options["AUTO_FORMAT" ] "Allows Excel style to be used";
         set $valid_options["AUTO_FORMAT_SELECT" ]
               "Allows Excel styles to be selected interactively";
             set $valid_options["EXCEL_SCALE"]
               "Scales the printed output of the worksheet";
         set $valid_options["EXCEL_ZOOM"]
               "Specifies zoom for the worksheet";
         set $valid_options["WORKSHEET_LOCATION"]
               "Provides the location for the beginning cell and row locations";
             set $valid_options["WORKSHEET_TEMPLATE"]
               "Provides an Excel template file for the basis for all new worksheets created";
         set $valid_options["EXCEL_AUTOFILTER" ]
               "Provides the ability to add filters to worksheet";
         set $valid_options["EXCEL_ORIENTATION" ]
               "Ability to modify the worksheet orientation";
         set $valid_options["EXCEL_TABLE_MOVE" ]
               "Ability to select which tables to export to worksheet";
         set $valid_options["EXCEL_FROZEN_HEADERS"]
               "Freezes column headers in Excel";
         set $valid_options["DELETE_SHEETS"]
               "specify the name of sheet to delete separated by commas";
		 set $valid_options["OUTPUT_TYPE"]
               "Modify the default output type of HTML to Script when creating pivot tables and charts";
         set $valid_options["FILE_FORMAT" ]
               "Determine the format of the exported tables(s)";
         set $valid_options["MACRO" ]
               "Specifies the location of a file and the name of the macro to execute";
         set $valid_options["EXCEL_DEFAULT_WIDTH" ]
               "Specifies default width of all Excel columns";
         set $valid_options["EXCEL_DEFAULT_HEIGHT" ]
               "Provides default height for all of the Excel columns";
         set $valid_options["QUERY_FILE" ]
               "Adds file that will be queried in Excel";
         set $valid_options["QUERY_RANGE" ]
               "Location on the worksheet to write the queried output";
         set $valid_options["UPDATE_TARGET" ]
               "Specifies the workbook to open for updating";
         set $valid_options["UPDATE_SHEET" ] "Specifies a worksheet to update";
         set $valid_options["UPDATE_RANGE" ]
               "Location on the workshet to begin writing";
         set $valid_options["PTSOURCE_RANGE" ]
               "Pivot Table source data to look at";
         set $valid_options["PTDEST_RANGE" ]
               "Creates pivot table on the same sheet based on the range";
         set $valid_options["PIVOTROW" ] "Adds row(s) to the pivot table";
         set $valid_options["PIVOTCOL" ] "Adds column(s) to the pivot table";
         set $valid_options["PIVOTDATA" ]
               "Adds data column(s) to the pivot table";
         set $valid_options["PIVOTPAGE" ] "Adds page field to the pivot table";
         set $valid_options["PIVOTROW_FMT" ] "Formats the row fields in the pivot table";
         set $valid_options["PIVOTCOL_FMT" ] "Formats the column fields in the pivot table";
         set $valid_options["PIVOTPAGE_FMT" ] "Formats the page fields in the pivot table";
         set $valid_options["PIVOTDATA_FMT" ] "Formats the data fields in the pivot table";
         set $valid_options["PIVOTDATA_STATS" ] "Prodives statisics for the data fields of the pivot tables";
         set $valid_options["PIVOTCALC" ] "Performs calculation on the statistics such as percentage of row, column and total";
         set $valid_options["PIVOT_FORMAT" ] "Specifies the Excel style to use";
         set $valid_options["PIVOTCHARTS" ] "Indicates that the charts created are pivotcharts";
         set $valid_options["PIVOT_SERIES"]
               "Specifies that yout will create multiple statistics from the same data source";
         set $valid_options["PIVOT_SUBTOTAL"]
               "Eliminates all subtotals created in the pivot table report";
         set $valid_options["PIVOT_GRANDTOTAL"]
               "Eliminates the grand totals generated by the pivot table";
         set $valid_options["PIVOTDATA_TOCOLUMNS"]
               "Places data values as individual columns rather than stacked cells on the row when there are multiple data values ";
         set $valid_options["PIVOTDATA_CAPTION"]
               "Provides a label for the captions  ";
         set $valid_options["PIVOTDATA_CAPTION" ]
               "Provides source dat for Excel Chart";
         set $valid_options["FORMAT_CONDITION"]
               "Allows data highlighting such as databar, icons and color scales";
        set $valid_options["ADDFIELD"]
               "Allows the generation of computed fields in the pivot table";
         set $valid_options["CHART_TYPE" ] "Type of Excel chart to display";
         set $valid_options["CHART_TITLE" ] "Specifies a title for the chart";
         set $valid_options["CHART_TITLE_COLOR" ]
               "Specifies a color for the title";
         set $valid_options["CHART_TITLE_SIZE" ]
               "Specifies a size for the title";
         set $valid_options["CHART_XAXES_TITLE" ]
               "Specifies a title for the X axes";
         set $valid_options["CHART_XAXES_SIZE" ]
               "Specifies size for the X axes title";
         set $valid_options["CHART_YAXES_TITLE" ]
               "Specifies a title for the Y Axes";
         set $valid_options["CHART_YAXES_SIZE" ]
               "Specifies size for the Y axes title";
         set $valid_options["CHART_AREA_COLOR" ]
               "Specifies color for chart area";
         set $valid_options["CHART_PLOTAREA_COLOR" ]
               "Specifies color for the plot area";
         set $valid_options["CHART_DATALABELS" ] "Apply data labels to charts";
             set $valid_options["CHART_LOCATION" ] "Specifies location to plce the chart";
         set $valid_options["CHART_POSITION" ] "Specifies top, left, height and width for embedded charts";
         set $valid_options["CHART_STYLE" ] "Specifies the style for charts and take values 1-47";
         set $valid_options["CHART_YAXES_ORIENTATION"] "modifies the orientation of the axis";
         set $valid_options["CHART_XAXES_ORIENTATION"] "modifies the orientation of the axis";
         set $valid_options["CHART_LEGEND"] "modifies the location of the legend";
         set $valid_options["CHART_YAXES_NUMBERFORMAT"] "modifies the format of the axis";
         set $valid_options["CHART_YAXES_MAXSCALE"] "modifies the axis scale";
         set $valid_options["CHART_YAXES_MINSCALE"] "modifies the axis scale";
         set $valid_options["CHART_LAYOUT"] "modifies the layout of the chart and take values 1-10";
         set $valid_options["POWERPOINT_MASTER" ]
               "Specifies text to display on the master slide";
         set $valid_options["POWERPOINT_SLIDES" ]
               "Specifies HTML files to provide as individual slides";
         set $valid_options["POWERPOINT_TEMPLATE" ]
               "Supplies a PowerPoint to use or the formatting";
         set $valid_options["POWERPOINT_MASTER" ]
               "Specifies text to display on the master slide";
         set $valid_options["POWERPOINT_SAVEAS" ]
               "Saves PowerPoint presentation to a slide";
         set $valid_options["POWERPOINT_RUN" ] "Runs PowerPoint presentation";
         set $valid_options["AUTO_EXCEL" ]
               "Starts export to Excel after the page has been loaded";
         set $valid_options["AUTO_POWERPOINT" ]
               "Starts export to PowerPoint after the page has been loaded";
         set $valid_options["DOC" ]
               "Displays short list of options and the options definition";
         set $valid_options["NOWRAP" ]
               "Prevents wrapped text in the browser or when exported to Excel";
        set $valid_options["EMBEDDED_TABLES" ]
               "Allows multiple tables included paneled tables in the Excel file";
        set $valid_options["EMBEDDED_TITLES" ]
               "Allows titles in the excel file when single sheet";
        set $valid_options["OPEN_IMAGE_PATH" ]
               "Adds image for the expanded nodes";
        set $valid_options["CLOSED_IMAGE_PATH" ]
               "Adds image for collasped nodes";
        set $valid_options["LEAF_IMAGE_PATH" ]
               "Adds image for item";
        set $valid_options["TOC_BACKGROUND" ]
               "Adds background color to the TOC";
        set $valid_options["TOC_EXPAND" ]
               "Expand TOC by default";
        set $valid_options["TOC_PRINT" ]
               "Adds a print button on the table of contents";
        set $valid_options["NUMBER_FORMAT" ]
               "Allows the ability to provide formats";
        set $valid_options["FORMAT_EMAIL" ]
               "Modifies the HTML so that the style information is preserved viewed in email";

      end;
      define event check_valid_TE_options;
         break /if ^$options;
         iterate $options;

         do /while _name_;

            do /if ^$valid_options[_name_];
               putlog "Unrecognized option: " _name_;
            done;

            next $options;
         done;

      end;
      define event list_TE_options;
         iterate $valid_options;
         putlog
               "==============================================================
================";
         putlog "Short descriptions of the supported options";
         putlog " For the full list of options see the PDF file in the download";
         putlog
               "==============================================================
================";
         putlog "Name     :   Description";
         putlog " ";

         do /while _name_;
            unset $option;
            set $option $options[_name_ ];
            set $option $option_defaults[_name_ ] /if ^$option;
            putlog _name_ " :   ";
            putlog "      " _value_;
           /* putlog " "; */
            next $valid_options;
         done;

         putlog " ";

         trigger list_chart_types;

      end;

      define event list_chart_types;
         trigger excelchart;
         iterate $graph;
         putlog
               "==============================================================
================";
         putlog "Valid graph types are listed below";
         putlog   "==============================================================
================";
         putlog "Chart    :   Name";
         putlog " ";

         do /while _name_;
            unset $option;
             set $option $options[_name_ ];
            set $option $option_defaults[_name_ ] /if ^$option;
            putlog  "Chart Type: " _name_;
            /*putlog " ";*/
            next $graph;
         done;

         putlog " ";
      end;

      define event doc;
         start:
            set $script "1" / if cmp($output_type,"script");
            break / if $script;
            set $doctype
               "<!DOCTYPE html PUBLIC ""-//W3C//DTD HTML 4.01 Transitional//EN"" " ;

            set $framedoctype
                  "<!DOCTYPE html PUBLIC ""-//W3C//DTD HTML 4.01 Frameset//EN"""
                  ">";
            put $doctype ;
            put '"http://www.w3.org/TR/html4/loose.dtd"' / if cmp($frozen_headers_all,"yes") and ^$frozen_rowheaders;
            put ">" NL;
            put "<html  xmlns:x=""urn:schemas-microsoft-com:office:excel"">" NL;

         finish:
            put "</html>" NL / if !$script;

            put $$xlstream / if $excel_options;

            do /if cmp( $options["REORDER_COLS"], "yes");

               trigger reorder;
            done;

            /* Removes extra scroll bar from Non I.E browsers */

            do / if cmp($frozen_headers,"yes");
                trigger remove_scrollbar;
            done;

            trigger fittopage / if cmp( $fit2page, "yes");

            put $$tbody;

            do /if cmp( $sort, "yes");
               put "<script>" NL;

               trigger sort;
               put "</script>" NL /if ^cmp( $autofilter, "yes");
            done;

            trigger autofilter /if cmp( $autofilter, "yes");
            trigger hide_columns / if cmp($hide_cols,"yes");
            trigger highlight / if $highlight_color;

      end;

      define event fittopage;
          put "<script>" NL;
          put "  function before() {" NL;
          iterate $keepid;

          do /while _value_;
              eval $jvar substr(_value_,3);
              eval $tmp cat("test",$jvar);
              eval $tmpbod cat("bid",$jvar);
              eval $tmphd cat("hid",$jvar);
              put "  var " $tmp "=" _value_ ".offsetWidth;" NL;

              do /if ^cmp( $options["ORIENTATION"], "landscape");
                 put "   if (" $tmp ">= 800)  {" $tmp "=650/" $tmp
                    %nrstr("*100 + '%%'");

              else;
                 put "   if (" $tmp ">= 900)  {" $tmp "=850/" $tmp
                    %nrstr("*100 + '%%'");
              done;

                 put "}" NL;
                 put "   else { " $tmp "=" $tmp "/" $tmp "}" NL;
                 put "   alert(" $tmp ")" NL /if $options["FIT2PAGE_MSG"];
                 put $tmpbod ".style.zoom=" $tmp ";" NL;
                 put $tmphd ".style.zoom=" $tmp ";" NL;
              next $keepid;
            done;

               put "}" NL;
               put "function after() {" NL;
               iterate $keepid;

               do /while _value_;
                  eval $jvar substr(_value_,3);
                  eval $tmp cat("test",$jvar);
                  eval $tmpbod cat("bid",$jvar);
                  eval $tmphd cat("hid",$jvar);
                  put $tmpbod %nrstr(".style.zoom=""100%%"";") NL;
                  put $tmphd %nrstr(".style.zoom=""100%%"";") NL;
                  next $keepid;
               done;

               put "}" NL;
               put "</script>" NL;
            done;
       end;

       define event hide_columns;
          put "<script>" NL;
          put "   function test(x) {" NL;
          put "     x.style.display=""none"" " NL;
          put "  } " NL;
          putl;
          put " function refresh() {" NL;
          put "  window.location.reload()" NL;
          put " }" NL;
          put "</script>" NL;
      end;
      /****************************************************/
      /* Sets up options that work when the we page loads */
      /****************************************************/
      define event startup_function;
         start:
            break / if $script;
            put "function startup(){" NL NL;
            putq "document.title=" $wtitle ";" /if exist( $wtitle);
            put "viewinit()" NL /if any( $options["PRINT_HEADER"], $options["PRINT_FOOTER"], $options["ORIENTATION"]);
            putq "body.style.backgroundColor=" $options["BACKGROUND_COLOR" ]  NL;

            do /if any( $options["SCROLLBAR_COLOR"], $options["SCROLLBAR_ARROW_COLOR"]);
               set $scrollbar_color $options["SCROLLBAR_COLOR" ];
               set $scrollbar_arrow_color $options["SCROLLBAR_ARROW_COLOR" ];
               put "if (document.all) {" NL;
               putq "document.body.style.scrollbarFaceColor =" $scrollbar_color NL;
               putq " document.body.style.ScrollArrowColor =" $scrollbar_arrow_color NL;
               put "}" NL;

            else;
               unset $scrollbar_color;
               unset $scrollbar_arrow_color;
            done;

            put "enableFilter()" NL /if cmp( $autofilter, "yes");
            putq "alert(" $alert_text ")" NL /if $alert_text;
            putq "window.status=" $window_status ";" NL /if $window_status;
            put "maintabs(""container1"", ""tab1"");" /if $web_tabs;

            do /if $window_size;
               do /if cmp( $window_size, "max");
                  put " window.resizeTo(screen.width,screen.height);" NL;
               else;
                  put " window.resizeTo(" $window_size ");" NL /if ^cmp( $window_size, "max");
              done;
           done;
           put " remscroll() " / if cmp($frozen_headers,"yes");


         finish:
            break / if $script;
            put TAGATTR NL;

            do /if any( $auto_excel, $auto_powerpoint);
               put " CopyExcel()" /if cmp( $auto_excel, "yes");
               put " CreatePPT()" /if cmp( $auto_powerpoint, "yes");
            done;

            put "}" NL;
      end;

        /****************************************/
        /* removes extra scroll bar from Firefox*/
        /****************************************/
      define event remove_scrollbar;
         put "<script>" NL;
         put " function  remscroll() {" NL;
         put "var _iea =navigator.appName;" NL;
         put "if (_iea =='Netscape') {" NL;
         put "var e=document.getElementsByTagName(""div"");" NL;
         put "for(var i=0;i<e.length;i++){e[i].style.overflow = ""hidden"";" NL;
         put "      }" NL;
         put "    } " NL;
         put "  }" NL;
         put "</script>";
     end;

  define event openexcel;
    put "<!--[if gte mso 9]><xml>" NL;
    put "<x:ExcelWorkbook>" NL;
    put " <x:ExcelWorksheets>" NL;
    put "   <x:ExcelWorksheet>" NL / if ^$worksheet_source;

    do / if $sheet;
       put "  <x:Name>" $sheet "</x:Name>" NL;
    else;
       put "   <x:Name>Sheet1</x:Name>" NL / if ^any($sheet,$worksheet_source);
    done;
     put "     <x:WorksheetOptions>" NL;
     put "       <x:Zoom>" $excel_zoom "</x:Zoom>" NL /  if $excel_zoom;
     put "       <x:Gridlines/>" NL / if $gridlines ;
  do / if $excel_frozen_headers;
     put "      <x:FreezePanes/>" NL;
     put "      <x:FrozenNoSplit/>" NL;
     put "      <x:SplitHorizontal>" $excel_frozen_headers "</x:SplitHorizontal>" NL;
     put "      <x:TopRowBottomPane>" $excel_frozen_headers "</x:TopRowBottomPane>" NL;
  done;
     put "      <x:Print>" NL;
     put "          <x:Scale>" $excel_scale "</x:Scale>" NL / if $excel_scale;
     put "          <x:ValidPrinterInfo/>" NL;
     put "    </x:Print>" NL;
     put "  </x:WorksheetOptions>" NL;
     put " </x:ExcelWorksheet>" NL;
     put " </x:ExcelWorksheets>" NL;
     put "</x:ExcelWorkbook>" NL;
     put "</xml><![endif]-->" NL;
  end;

  /*****************************************************/
  /* Adds load message or load image while page loading*/
  /*****************************************************/

  define event load_message;
      put "<div id=""wrap"" style=""position:absolute;left:expression(document.body.clientWidth/2);";
      put "top:expression(document.body.clientWidth/2);"">" NL;
      put "<p id=""load"">Loading....please wait</p>" NL /if $loadmsg;
      putq "<img id=""loadimg"" src=" $loadimg "/>" /if $loadimg;
      put "</div>" NL;
      put "<script>" NL;
      put "document.onreadystatechange=fnStartInit;" NL;
      put "function fnStartInit(){" NL;
      put "  if (""complete"" !=this.readyState){ " NL;
      put "}" NL;
      put "else {" NL;
      put "load.innerText="""";" NL /if $loadmsg;
      put "loadimg.outerHTML="""";" NL /if $loadimg;
      put "wrap.outerHTML="""";" NL;
      put "}" NL;
      put " }" NL;
      put "</script>" NL;
      put NL;
 end;

 /***********************************************/
 /* Sets up drag and drop for items on the page */
 /***********************************************/

 define event drag_drop;
    put "<style>" NL;
    put ".ProcTitle,Table,.Systemtitle,img {cursor:hand;position:relative !important};" NL;
    put "</style>" NL;
    put "<script language=""JavaScript1.2"">" NL;
    put "  var drag=false" NL;
    put "  var z,x,y" NL;
    put "function move(){" NL;
    put %nrstr("if %(event.button==1&&drag%){") NL;
    put " z.style.pixelLeft=temp1+event.clientX-x" NL;
    put " z.style.pixelTop=temp2+event.clientY-y" NL;
    put "return false" NL;
    put "}" NL;
    put "}" NL;
    put "function moveall(){" NL;
    put " if (!document.all)" NL;
    put "  return" NL;
    put "  if (event.srcElement.tagName==""A"" ||event.srcElement.tagName==""IMG"" || event.srcElement.tagName==""TABLE"" ||
event.srcElement.tagName==""TD"" || event.srcElement.tagName==""P""){" NL;
    put "   drag=true" NL;
    put "   z=event.srcElement" NL;
    put "   temp1=z.style.pixelLeft" NL;
    put "   temp2=z.style.pixelTop" NL;
    put "   x=event.clientX" NL;
    put "   y=event.clientY" NL;
    put "document.onmousemove=move" NL;
    put " }" NL;
    put "}" NL;
    put "document.onmousedown=moveall" NL;
    put "document.onmouseup=new Function(""drag=false"")" NL;
    put "</script>" NL;
 end;

 /********************************************/
 /* Adds Web tabs for output on the Web page */
 /********************************************/
 define event web_tabs;
     put "<script>" NL;
     put "var panes = new Array();" NL;
     put " function maintabs(containerId, defaultTabId) {" NL;
     put " panes[containerId] = new Array();" NL;
     put " var container = document.getElementById(containerId);" NL;
     put " var paneContainer = container.getElementsByTagName(""div"")[0];" NL;
     put " var paneList = paneContainer.childNodes;" NL;
     put " for (var i=0; i < paneList.length; i++ ) {" NL;
     put " var pane = paneList[i];" NL;
     put " if (pane.nodeType != 1) continue;" NL;
     put " panes[containerId][pane.id] = pane;" NL;
     put " pane.style.display = ""none"";" NL;
     put "}" NL;
     put " document.getElementById(defaultTabId).onclick();" NL;
     put "}" NL;
     put "function showPane(paneId, activeTab) {" NL;
     put " for (var con in panes) {" NL;
     put " activeTab.blur();" NL;
     put " activeTab.className = ""Header"";" NL;
     put " if (panes[con][paneId] != null) {" NL;
     put "   var pane = document.getElementById(paneId);" NL;
     put "   pane.style.display = ""block"";" NL;
     put "   var container = document.getElementById(con);" NL;
     put "   var tabs = container.getElementsByTagName(""ul"")[0];"  NL;
     put "   var tabList = tabs.getElementsByTagName(""a"")" NL;
     put "   for (var i=0; i<tabList.length; i++ ) {" NL;
     put "     var tab = tabList[i];" NL;
     put "     if (tab != activeTab) tab.className = ""Data"";" NL;
     put "   }" NL;
     put "   for (var i in panes[con]) {" NL;
     put "     var pane = panes[con][i];" NL;
     put "     if (pane == undefined) continue;" NL;
     put "     if (pane.id == paneId) continue;" NL;
     put "     pane.style.display = ""none"" " NL;
     put "   }" NL;
     put " }" NL;
     put "}" NL;
     put "return false;" NL;
     put "}" NL;
     put "</script>" NL;
end;

/***************************************************/
/* Sets up available file formats for Excel output */
/***************************************************/

define event file_format;
    set $export_format["xls" ] "1";
    set $export_format["slk" ] "2";
    set $export_format["txt" ] "3";
    set $export_format["csv" ] "6";
    set $export_format["prn" ] "36";
    set $export_format["html" ] "44";
    set $export_format["xml" ] "46";
    set $export_format["xlsx" ] "51";
    set $export_format["xlsb" ] "50";
    set $export_format["xlsm" ] "52";
    set $export_format["doc" ] "99";
    set $file_format lowcase($file_format);
end;

/****************************************/
/* Sets up auto formats for Excel output*/
/****************************************/

define event auto_format;
   set $excel_format["3deffects1" ] "31";
   set $excel_format["3deffects2" ] "14";
   set $excel_format["accounting1" ] "4";
   set $excel_format["accounting2" ] "5";
   set $excel_format["accounting3" ] "6";
   set $excel_format["accounting4" ] "17";
   set $excel_format["classic1" ] "1";
   set $excel_format["classic2" ] "2";
   set $excel_format["classic3" ] "3";
   set $excel_format["classicpivottable" ] "31";
   set $excel_format["color1" ] "7";
   set $excel_format["colorful1" ] "7";
   set $excel_format["color2" ] "8";
   set $excel_format["colorful2" ] "8";
   set $excel_format["color3" ] "9";
   set $excel_format["colorful3" ] "9";
   set $excel_format["list1" ] "10";
   set $excel_format["list2" ] "11";
   set $excel_format["list3" ] "12";
   set $excel_format["format1" ] "15";
   set $excel_format["format2" ] "16";
   set $excel_format["format3" ] "19";
   set $excel_format["format4" ] "20";
   set $excel_format["none" ] "34";
   set $excel_format["ptnone" ] "42";
   set $excel_format["report1" ] "21";
   set $excel_format["simple" ] "54";
   set $excel_format["table1" ] "23";
   set $excel_format["table10" ] "41";
   set $excel_format["table9" ] "33";
   set $excel_format["light1" ] "TableStyleLight1";
   set $excel_format["light2" ] "TableStyleLight2";
   set $excel_format["light3" ] "TableStyleLight3";
   set $excel_format["light4" ] "TableStyleLight4";
   set $excel_format["light5" ] "TableStyleLight5";
   set $excel_format["light6" ] "TableStyleLight6";
   set $excel_format["light7" ] "TableStyleLight7";
   set $excel_format["light8" ] "TableStyleLight8";
   set $excel_format["light9" ] "TableStyleLight9";
   set $excel_format["light10" ] "TableStyleLight10";
   set $excel_format["light11" ] "TableStyleLight11";
   set $excel_format["light12" ] "TableStyleLight12";
   set $excel_format["light13" ] "TableStyleLight13";
   set $excel_format["light14" ] "TableStyleLight14";
   set $excel_format["light15" ] "TableStyleLight15";
   set $excel_format["light16" ] "TableStyleLight16";
   set $excel_format["light17" ] "TableStyleLight17";
   set $excel_format["light18" ] "TableStyleLight18";
   set $excel_format["light19" ] "TableStyleLight19";
   set $excel_format["light20" ] "TableStyleLight20";
   set $excel_format["light21" ] "TableStyleLight21";
   set $excel_format["light10" ] "TableStyleLight10";
   set $excel_format["light11" ] "TableStyleLight11";
   set $excel_format["light12" ] "TableStyleLight12";
   set $excel_format["medium1" ] "TableStyleMedium1";
   set $excel_format["medium2" ] "TableStyleMedium2";
   set $excel_format["medium3" ] "TableStyleMedium3";
   set $excel_format["medium4" ] "TableStyleMedium4";
   set $excel_format["medium5" ] "TableStyleMedium5";
   set $excel_format["medium6" ] "TableStyleMedium6";
   set $excel_format["medium7" ] "TableStyleMedium7";
   set $excel_format["medium8" ] "TableStyleMedium8";
   set $excel_format["medium9" ] "TableStyleMedium9";
   set $excel_format["medium10" ] "TableStyleMedium10";
   set $excel_format["medium11" ] "TableStyleMedium11";
   set $excel_format["medium12" ] "TableStyleMedium13";
   set $excel_format["medium13" ] "TableStyleMedium13";
   set $excel_format["medium14" ] "TableStyleMedium14";
   set $excel_format["medium15" ] "TableStyleMedium15";
   set $excel_format["medium16" ] "TableStyleMedium16";
   set $excel_format["medium17" ] "TableStyleMedium17";
   set $excel_format["medium18" ] "TableStyleMedium18";
   set $excel_format["medium19" ] "TableStyleMedium19";
   set $excel_format["medium20" ] "TableStyleMedium20";
   set $excel_format["medium21" ] "TableStyleMedium21";
   set $excel_format["medium22" ] "TableStyleMedium22";
   set $excel_format["medium23" ] "TableStyleMedium23";
   set $excel_format["medium24" ] "TableStyleMedium24";
   set $excel_format["medium25" ] "TableStyleMedium25";
   set $excel_format["medium26" ] "TableStyleMedium26";
   set $excel_format["medium27" ] "TableStyleMedium27";
   set $excel_format["medium28" ] "TableStyleMedium28";
   set $excel_format["dark1" ] "TableStyleDark1";
   set $excel_format["dark2" ] "TableStyleDark2";
   set $excel_format["dark3" ] "TableStyleDark3";
   set $excel_format["dark4" ] "TableStyleDark4";
   set $excel_format["dark5" ] "TableStyleDark5";
   set $excel_format["dark6" ] "TableStyleDark6";
   set $excel_format["dark7" ] "TableStyleDark7";
   set $excel_format["dark8" ] "TableStyleDark8";
   set $excel_format["dark8" ] "TableStyleDark8";
   set $excel_format["dark10" ] "TableStyleDark10";
   set $excel_format["dark11" ] "TableStyleDark11";
   set $excel_format["dark12" ] "TableStyleDark12";

   set $auto_format lowcase($auto_format);

 end;

/*****************************************************/
/* Adds information which needs to go into the header */
/* of the page. Also adds Excel options to the list  */
/* which adds a button to the page when option added */
/*****************************************************/
define event doc_head;
    start:
       break / if $script;
       put "<head>" NL;
       put "<meta http-equiv=""X-UA-Compatible"" content=""IE=EmulateIE7"" />" NL / if cmp($options['FROZEN_HEADERS_ALL'],"yes");


       put "thead.style.textDecoration=""underline"" " NL /if cmp($option["UNDERLINE"], "yes");

        do /if $options["IMAGE_JUST"];
           set $image_just $options["IMAGE_JUST" ];
           put "<div style=""text-align:";
           put $image_just;
           put """>";

         else;
            unset $image_just;
        done;

        do /if $options["IMAGE_PATH"];
            set $image_path $options["IMAGE_PATH" ];
            putq "<img src=" $image_path ">" NL /if cmp( dest_file, "body");
        done;

            put "</div>" NL /if $options["IMAGE_JUST"];
            put VALUE NL;
            set $body_name upcase(body_name);

          do / if contains($body_name,".XLS");
             set $excel_options "true";
             set $switch_titles "yes";

           do /if any( $orientation,$header_data,$footer_data);
               put "<style> @page {";
               put "mso-page-orientation:landscape; "  / if cmp($orientation,"landscape");
               putq "mso-header-data:" $header_data;
               put ";" / if $footer_data;
               putq " mso-footer-data:" $footer_data;
               put "}</style>" NL;
          done;
             put VALUE NL;
         done;

         finish:

         trigger openexcel / if contains($body_name,".XLS");
         trigger load_message / if any( $loadmsg, $loadimg);
         trigger drag_drop / if cmp( $options["DRAG"], "yes");

          do /if cmp( $sort, "yes") and cmp ( $autofilter , "yes");
             put "<script>" NL;
             put "  function errorset() {" NL;
             put "      return true;" NL;
             put "    }" NL;
             put "  window.onerror=errorset;" NL;
             put "</script>" NL;
          done;


          trigger web_tabs / if $web_tabs;
          trigger powerpoint /if $slides;
          trigger excel_options;

          do /if any( $excel_frozen_headers, $excel_sheet_prompt, $excel_save_prompt, $excel_save_dialog, $excel_autofilter,
                     $excel_orientation, $excel_table_move, $file_format, $excel_zoom,$excel_scale, $excel_save_file, $macro, $excel_default_width,
                     $excel_default_height, $query_file,$update_sheet, $update_target, $update_range,$ptsource_range, $ptdest_range, $pivotrow, $pivotcol,
                     $pivotdata, $pivotpage, $sheet, $insert_sheet, $chart_type, $chart_source, $auto_format, $auto_excel, $number_format,
                     $options["AUTO_FORMAT_SELECT"],$format_email,$worksheet_location,$worksheet_template,$sheet_interval,$chart_style,$chart_xaxes_orientation,
                     $chart_yaxes_numberformat,$chart_yaxes_maxscale,$chart_yaxes_minscale,$pivot_format);

               set $excel_options "true";
               trigger file_format;
               trigger auto_format / if $auto_format;
                  do /if $query_file;
                     put " var query=sheet.QueryTables.Add(Connection=""URL;file:////";
                     put $query_file """,";
                     putq " Destination=sheet.Range(" $query_range "));" NL;
                     put " query.QueryTable;" NL;
                     put " query.PreserveFormatting = 1;" NL;
                     put " query.SaveData = 1;" NL;
                     put " query.RefreshStyle = 0;" NL;
                     put " query.AdjustColumnWidth=0;" NL;
                     put " query.FieldNames =1;" NL;
                     put " query.BackgroundQuery = 0;" NL;
                     put " query.WebSelectionType = 2;" NL;
                     putq " query.WebTables = " $excel_table_move ";" NL /if $query_file;
                     put " query.Refresh( BackgroundQuery=1);" NL;
                  done;

               done;


      do /if $options["SAVEAS"];
         put "<input class=""button"" onclick=""document.execCommand('SAVEAS',true ";
         put ",'" $options["DEFAULT_FILE" ] "')""" /if $options["DEFAULT_FILE" ];
         put ")""" /if ^$options["DEFAULT_FILE"];
         put " value=""Save As"" type=""button"">" NL;
      done;

      put "</head>" NL / if !$script;

end;
/************************************************************/
/* Sets up the number format when output goes over to Excel */
/************************************************************/


define event num_lookup;
   set $nflookup[] "A:A";
   set $nflookup[] "B:B";
   set $nflookup[] "C:C";
   set $nflookup[] "D:D";
   set $nflookup[] "E:E";
   set $nflookup[] "F:F";
   set $nflookup[] "G:G";
   set $nflookup[] "H:H";
   set $nflookup[] "I:I";
   set $nflookup[] "J:J";
   set $nflookup[] "K:K";
   set $nflookup[] "L:L";
   set $nflookup[] "M:M";
   set $nflookup[] "O:O";
   set $nflookup[] "P:P";
   set $nflookup[] "Q:Q";
   set $nflookup[] "R:R";
   set $nflookup[] "S:S";
   set $nflookup[] "T:T";
   set $nflookup[] "U:U";
   set $nflookup[] "V:V";
   set $nflookup[] "W:W";
   set $nflookup[] "X:X";
   set $nflookup[] "Y:Y";
   set $nflookup[] "Z:Z";

   do /if index($number_format,"|");
      set $number_value scan($number_format,1,"|");
      eval $countnf 1;

      do /while ^cmp( $number_value," ");
         set $nf_row[] strip($number_value);
         eval $countnf $countnf +1;
         set $number_value scan($number_format,$countnf,"|");
      done;


   else;
      set $nf_row[] strip($number_format);
   done;

   eval $nfcountr 1;
   iterate $nf_row;

   do /while _value_;
      putq " xl.Range(" $nflookup[$nfcountr] ").NumberFormat=" _value_ ";" NL;
      eval $nfcountr $nfcountr +1;
      next $nf_row;
   done;

done;

unset $number_format;
unset $options["NUMBER_FORMAT" ];
end;

define event datalabels;

   set $chartdata["percent"] "3";
   set $chartdata["value"] "2";
   set $chartdata["labelandpercent"] "5";
   set $chartdata["showbubblesizes"] "6";
   set $chartdata["label"] "4";
   set $chart_datalabels lowcase($chart_datalabels);
end;


define event chartlegend;
  set $legend["bottom"] "-4107";
  set $legend["corner"] "2";
  set $legend["left"] "-4107";
  set $legend["right"] "-4152";
  set $legend["top"] "-4160";
  set $chart_legend lowcase($chart_legend);
end;


/*********************************************/
/* Adds chart options tables output to Excel */
/*********************************************/

define event chartoptions;
do /if exist($chart_title);
    put " ch.HasTitle=1;" NL;
    putq " ch.ChartTitle.Text=" $chart_title ";" NL;
    put " ch.ChartTitle.Font.Size=" $chart_title_size ";"  NL / if $chart_title_size;
    putq " ch.ChartTitle.Font.ColorIndex=" $chart_title_color  ";" NL / if $chart_title_color;
done;

do /if exist($chart_xaxes_title);
    put " ch.Axes(1,1).HasTitle = 1;" NL;
    putq " ch.Axes(1,1).AxisTitle.Characters.Text =" $chart_xaxes_title ";" NL / if $chart_xaxes_title;
    put " ch.Axes(1,1).AxisTitle.Font.Size=" $chart_xaxes_size ";" NL /if $chart_xaxes_size;
    put "  ch.Axes(1,1).TickLabels.Orientation =" $chart_xaxes_orientation ";" NL /if $chart_xaxes_orientation;

done;

do /if exist($chart_yaxes_title);
    put " ch.Axes(2).HasTitle = 1;" NL;
    putq " ch.Axes(2).AxisTitle.Characters.Text =" $chart_yaxes_title ";" NL;
    put " ch.Axes(2).AxisTitle.Font.Size =" $chart_yaxes_size ";" NL /if $chart_yaxes_size;
    put "  ch.Axes(2).TickLabels.Orientation =" $chart_yaxes_orientation ";" NL /if $chart_yaxes_orientation;
    put "  ch.Axes(2).MaximumScale=" $chart_yaxes_maxscale ";" NL /  if  $chart_yaxes_maxscale;
    put "  ch.Axes(2).MinimumScale=" $chart_yaxes_minscale ";" NL /  if  $chart_yaxes_minscale;
    put "  ch.Axes(2).NumberFormat=" $chart_yaxes_numberformat ";" NL /  if  $chart_yaxes_numberformat;
done;

 do /if any($chart_area_color,$chart_plotarea_color,$chart_datalabels,$chart_style,$chart_label,$chart_format);
      putq " ch.ChartArea.Interior.ColorIndex=" $chart_area_color ";" NL /if $chart_area_color;
      putq " ch.PlotArea.Interior.ColorIndex=" $chart_plotarea_color ";" NL /if $chart_plotarea_color;
      trigger datalabels;
      put " ch.Chart.ApplyDataLabels(" $chartdata[$chart_datalabels] ");" NL / if $chart_datalabels;
      putq  " ch.ChartStyle=" $chart_style ";" NL / if $chart_style;
      put "  ch.ApplyLayout(" $chart_layout ");" NL /  if $chart_layout;
      trigger chartlegend / if $chart_legend;

      do / if $chart_legend;
          do / if cmp($chart_legend,"none");
             put " ch.HasLegend=0;"  NL;
          else;
             put " ch.Legend.Position=" $legend[$chart_legend] ";" NL;
          done;
      done;

 done;
end;

/********************************************/
/* Chart options for embedded charts        */
/********************************************/

define event embedded_chartoptions;
       do /if exist($chart_title);
          put "ch.Chart.HasTitle=1;" NL;
          putq "ch.Chart.ChartTitle.Text=" $chart_title ";" NL;
          put " ch.Chart.ChartTitle.Font.Size=" $chart_title_size ";"  NL / if $chart_title_size;
          putq " ch.Chart.ChartTitle.Font.ColorIndex=" $chart_title_color  ";" NL / if $chart_title_color;
        done;

         do /if exist($chart_xaxes_title);
             put "ch.Chart.Axes(1,1).HasTitle = 1;" NL;
             putq "ch.Chart.Axes(1,1).AxisTitle.Characters.Text =" $chart_xaxes_title ";" NL / if $chart_xaxes_title;
             put "ch.Chart.Axes(1,1).AxisTitle.Font.Size=" $chart_xaxes_size ";" NL /if $chart_xaxes_size;
             put "  ch.Axes(1,1).TickLabels.Orientation =" $chart_xaxes_orientation ";" NL /if $chart_xaxes_orientation;

        done;

         do /if exist($chart_yaxes_title);
            put "ch.Chart.Axes(2).HasTitle = 1;" NL;
            putq "ch.Chart.Axes(2).AxisTitle.Characters.Text =" $chart_yaxes_title ";" NL;
            put "ch.Chart.Axes(2).AxisTitle.Font.Size =" $chart_yaxes_size ";" NL /if $chart_yaxes_size;
            put "  ch.Axes(2).TickLabels.Orientation =" $chart_yaxes_orientation ";" NL /if $chart_yaxes_orientation;
         done;

         do / if any($chart_area_color,$chart_plotarea_color,$chart_datalabels,$chart_style,$chart_layout);
            putq "ch.Chart.ChartArea.Interior.ColorIndex=" $chart_area_color ";" NL /if $chart_area_color;
            putq "ch.Chart.PlotArea.Interior.ColorIndex=" $chart_plotarea_color ";" NL /if $chart_plotarea_color;
            putq  " ch.ChartStyle=" $chart_style  ";" NL / if $chart_style;
            put " ch.ApplyLayout(" $chart_layout ");" NL /  if $chart_layout;
            trigger datalabels;
            put " ch.Chart.ApplyDataLabels(" $chartdata[$chart_datalabels] ");" NL / if $chart_datalabels;
            trigger chartlegend / if $chart_legend;

            do / if $chart_legend;
              do / if cmp($chart_legend,"none");
                put " ch.HasLegend=0;"  NL;
              else;
                put " ch.Legend.Position=" $legend[$chart_legend] ";" NL;
              done;
           done;

     done;
end;

/*************************************/
/* Chart options for pivot tables    */
/*************************************/

define event pivot_chartoptions;

do /if exist($chart_title);
          put " ach.HasTitle=1;" NL;
          putq " ach.ChartTitle.Text=" $chart_title ";" NL;
          put " ach.ChartTitle.Font.Size=" $chart_title_size ";"  NL /if $chart_title_size;
          putq " ach.ChartTitle.Font.ColorIndex=" $chart_title_color  ";" NL /if $chart_title_color;
     done;

     do /if any($chart_xaxes_title,$chart_xaxes_orientation,$chart_xaxes_maxscale,$chart_xaxes_minscale,$chart_xaxes_numberformat);

         put " ach.HasTitle=1;" NL;
         put " ach.Axes(1,1).HasTitle = 1;" NL;
         putq " ach.Axes(1,1).AxisTitle.Characters.Text =" $chart_xaxes_title ";" NL / if $chart_xaxes_title;
         put " ach.Axes(1,1).AxisTitle.Font.Size=" $chart_xaxes_size ";" NL /if $chart_xaxes_size;
         put " ach.Axes(1,1).TickLabels.Orientation =" $chart_xaxes_orientation ";" NL /if $chart_xaxes_orientation;
         put " ach.Axes(1).MaximumScale=" $chart_yaxes_maxscale ";" NL /  if  $chart_xaxes_maxscale;
         putq " ach.Axes(1).MinimumScale=" $chart_yaxes_minscale ";" NL /  if  $chart_xaxes_minscale;
         putq " ach.Axes(1).TickLabels.NumberFormat=" $chart_yaxes_numberformat ";" NL /  if  $chart_xaxes_numberformat;

   done;

    do /if any($chart_yaxes_title,$chart_yaxes_orientation,$chart_yaxes_maxscale,$chart_yaxes_minscale,$chart_yaxes_numberformat);
        put " ach.Axes(2).HasTitle = 1;" NL;
        putq " ach.Axes(2).AxisTitle.Characters.Text =" $chart_yaxes_title ";" NL;
        put " ach.Axes(2).AxisTitle.Font.Size =" $chart_yaxes_size ";" NL /if $chart_yaxes_size;
        put " ach.Axes(2).TickLabels.Orientation =" $chart_yaxes_orientation ";" NL /if $chart_yaxes_orientation;
        put " ach.Axes(2).MaximumScale=" $chart_yaxes_maxscale ";" NL /  if  $chart_yaxes_maxscale;
        put " ach.Axes(2).MinimumScale=" $chart_yaxes_minscale ";" NL /  if  $chart_yaxes_minscale;
        putq " ach.Axes(2).TickLabels.NumberFormat=" $chart_yaxes_numberformat ";" NL /  if  $chart_yaxes_numberformat;

    done;

   do / if any($chart_area_color,$chart_plotarea_color,$chart_datalabels,$chart_style,$chart_legend,$chart_layout);
        putq " ach.ChartArea.Interior.ColorIndex=" $chart_area_color ";" NL /if $chart_area_color;
        putq " ach.PlotArea.Interior.ColorIndex=" $chart_plotarea_color ";" NL /if $chart_plotarea_color;
        putq  " ach.ChartStyle=" $chart_style ";" NL / if $chart_style;
        trigger datalabels / if $chart_datalabels;
        put " ach.ApplyDataLabels(" $chartdata[$chart_datalabels] ");" NL /  if $chart_datalabels;;
        put " ach.ApplyLayout(" $chart_layout ");" NL /  if $chart_layout;
        trigger chartlegend / if $chart_legend;

        do / if $chart_legend;
          do / if cmp($chart_legend,"none");
             put " ach.HasLegend=0;"  NL;
          else;
             put " ach.Legend.Position=" $legend[$chart_legend] ";" NL;
          done;
        done;
   done;
end;


/****************************************************/
/* This event adds chart types for the Excel graphs */
/* based on the selection picked.                   */
/****************************************************/

define event excelchart;
   set $graph["cylindercol" ] "98";
   set $graph["barclustered" ] "57";
   set $graph["3dbarclustered" ] "60";
   set $graph["3dbarstacked" ] "61";
   set $graph["3dbarstacked100" ] "62";
   set $graph["barstacked" ] "58";
   set $graph["barstacked100" ] "59";
   set $graph["barofpie" ] "71";
   set $graph["bubble" ] "15";
   set $graph["bubble3deffect"] "15";
   set $graph["histogram" ] "51";
   set $graph["stackedhistogram" ] "52";
   set $graph["piechart" ] "5";
   set $graph["pie" ] "5";
   set $graph["pieexploded" ] "69";
   set $graph["pieofpie" ] "68";;
   set $graph["3dpie" ] "-4102";
   set $graph["3dpieexploded" ] "70";
   set $graph["cylinderbarclustered" ] "95";
   set $graph["cylinderbarstacked" ] "96";
   set $graph["cylinderbarstacked100" ] "97";
   set $graph["cylindercol" ] "98";
   set $graph["cylindercolclustered" ] "92";
   set $graph["cylindercolclustered100" ] "94";
   set $graph["area" ] "1";
   set $graph["areastacked"] "76";
   set $graph["areastacked100"] "77";
   set $graph["3darea" ] "-4098";
   set $graph["3dareastacked" ] "58";
   set $graph["3dareastacked100" ] "79";
   set $graph["bubble3deffect" ] "87";
   set $graph["columnclustered" ] "51";
   set $graph["columnstacked" ] "52";
   set $graph["columnstacked100" ] "53";
   set $graph["3dcolumn" ] "-4100";
   set $graph["3dcolumnclustered" ] "54";
   set $graph["3dcolumnstacked" ] "55";
   set $graph["3dcolumnstacked100"] "56";
   set $graph["conecol" ] "105";
   set $graph["conecolstacked" ] "100";
   set $graph["conecolstacked100" ] "101";
   set $graph["conebarclustered" ] "102";
   set $graph["conebarstacked" ] "103";
   set $graph["conebarstacked100" ] "104";
   set $graph["conecolclustered" ] "99";
   set $graph["dougnut" ] "-4120";
   set $graph["dougnutexploded" ] "80";
   set $graph["pyramidbarclustered" ] "109";
   set $graph["pyramidbarstacked" ] "110";
   set $graph["pyramidbarstacked100" ] "111";
   set $graph["pyramidcol" ] "112";
   set $graph["pyramidcolclustered"] "106";
   set $graph["pyramidcolstacked"] "107";
   set $graph["pyramidcolstacked100"] "108";
   set $graph["xyscatter" ] "-4169";
   set $graph["xyscatterlines" ] "74";
   set $graph["xyscatterlinesnomarker" ] "75";
   set $graph["xyscattersmooth" ] "72";
   set $graph["xyscattersmoothnomarkers" ] "73";
   set $graph["line"] "4";
   set $graph["linemarkers" ] "65";
   set $graph["linestacked" ] "63";
   set $graph["linestacked100" ] "64";
   set $graph["linemarkersstacked" ] "66";
   set $graph["linemarkersstacked100" ] "67";
   set $graph["3dline" ] "-4101";
   set $graph["radar" ] "-4151";
   set $graph["radarfilled" ] "82";
   set $graph["radarmarkers" ] "81";
   set $graph["stockhlc" ] "88";
   set $graph["stockohlc" ] "89";
   set $graph["stockvhlc" ] "90";
   set $graph["stockvohlc" ] "91";
   set $graph["surface" ] "83";
   set $graph["surfacetopview" ] "85";
   set $graph["surfacetopviewwireframe" ] "85";
   set $graph["surfacewireframe"] "85";
   set $chart_type lowcase($chart_type);


    do /if exist( $chart_type) ;
      do / if !cmp($pivotcharts,"yes") ;
          do /  if !cmp($chart_location,"new_sheet") and $chart_location;

        /* do / if cmp($chart_location,"same_sheet") ;*/

           put "// Add new chart" NL;

          do / if $chart_source;
             putq " var rang = sheet.Range(" $chart_source ");" NL;
             put " var ch = wb.Charts.Add();" NL;
             putq " ch.ChartType =" $graph[$chart_type ] ";" NL;
             put " ch.SetSourceData(rang);" NL;

         else;
            putq " var prang=wb.sheets("  $sheet_name ").UsedRange;" NL;
            put " var ch = sheet.Parent.Charts.Add();" NL;
            putq " ch.ChartType =" $graph[$chart_type ] ";" NL;
            put " ch.SetSourceData(prang);" NL;
        done;

         putl;

         trigger chartoptions;

         do / if cmp($chart_location,"same_sheet");
                 putq " ch.Location(2," $sheet_name ");" NL;
             else;
             putq " ch.Location(2," $chart_location ");" NL;
         done;

             /*****************************/
             /* Sets up the chart positon */
             /*****************************/

           do / if $chart_position;
                put "var chpos=sheet.ChartObjects(" $test_count ");" NL;
                eval $cpcnt count($chart_position,",");

                  do / if $cpcnt=0;
                     put " chpos.Top=" $chart_position;
                  else / if $cpcnt=1;

                     put " chpos.Top=" scan($chart_position,1) NL;
                     put " chpos.Left=" scan($chart_position,2) NL;
                  else / if $cpcnt=2;
                     put " chpos.Top=" scan($chart_position,1) NL;
                     put " chpos.Left=" scan($chart_position,2) NL;
                     put " chpos.Height=" scan($chart_position,3) NL;
                  else / if $cpcnt=3;

                     put " chpos.Top=" scan($chart_position,1) NL;
                     put " chpos.Left=" scan($chart_position,2) NL;
                     put " chpos.Height=" scan($chart_position,3) NL;
                     put " chpos.Width=" scan($chart_position,4) NL;
               done;

       done;

       else;
            put "// Add new chart from worksheet" NL;
            put " var ch = wb.Charts.Add(wb.Sheets(wb.Sheets.Count));" NL;
            putq " var ch=wb.ActiveChart;" NL;

             do / if $chart_source;
                putq " var rang = sheet.Range(" $chart_source ");" NL;
                put " ch.SetSourceData(rang);" NL;
            else;
                putq " var prang=wb.sheets("  $sheet_name ").UsedRange;" NL;
                put " ch.SetSourceData(prang);" NL;
           done;

           putq " ch.ChartType =" $graph[$chart_type ] ";" NL;
           eval $chart_name cat($sheet_name,"_chart");
           putq " ch.Name=" $chart_name ";" NL;
           putl;

         trigger chartoptions;

      done;
      else;

      do /  if !cmp($chart_location,"new_sheet") and $chart_location;
         putl;
         put "// Create pivot charts in same sheet " NL;
         eval $pivot_sheet cat($sheet_name,"_pivot");;

         do / if $chart_source;
             putq " var rang = pws.Range(" $chart_source ");" NL;
             put " var ch = wb.Charts.Add();" NL;
             putq " ch.ChartType =" $graph[$chart_type ] ";" NL;
             put " ch.SetSourceData(rang);" NL;

         else;
            putq " var prang=wb.sheets("  $pivot_sheet ").UsedRange;" NL;
            put " var ch = pws.Parent.Charts.Add();" NL;
            putq " ch.ChartType =" $graph[$chart_type ] ";" NL;
            put " ch.SetSourceData(prang);" NL;
        done;

         putl;

         trigger chartoptions;

         do / if cmp($chart_location,"same_sheet");
             putq " ch.Location(2," $pivot_sheet ");" NL;
          else;
             putq " ch.Location(2," $chart_location ");" NL;
         done;

             /* Testing Chart Options */

        do / if $chart_position;
            put " var chpos=pws.ChartObjects(" $test_count ");" NL;

            eval $cpcnt count($chart_position,",");

                  do / if $cpcnt=0;
                     put " chpos.Top=" $chart_position;
                  else / if $cpcnt=1;

                     put " chpos.Top=" scan($chart_position,1) NL;
                     put " chpos.Left=" scan($chart_position,2) NL;
                  else / if $cpcnt=2;
                     put " chpos.Top=" scan($chart_position,1) NL;
                     put " chpos.Left=" scan($chart_position,2) NL;
                     put " chpos.Height=" scan($chart_position,3) NL;
                  else / if $cpcnt=3;

                     put " chpos.Top=" scan($chart_position,1) NL;
                     put " chpos.Left=" scan($chart_position,2) NL;
                     put " chpos.Height=" scan($chart_position,3) NL;
               put " chpos.Width=" scan($chart_position,4) NL;
               done;

       done;


    else;
      putl;
      put "// Adding new pivot table chart sheet " NL;


      put " var ch = wb.Charts.Add(wb.Sheets(wb.Sheets.Count));" NL;
      eval $pivot_sheet cat($sheet_name,"_pivot");
      putq " var ach=wb.ActiveChart;" NL;

      do / if $chart_source;
          putq " var rang = pws.Range(" $chart_source ");" NL;
          put " ach.SetSourceData(rang);" NL;
      else;
          putq " var prang=wb.sheets("  $pivot_sheet ").UsedRange;" NL;
          put " ach.SetSourceData(prang);" NL;
      done;

      putq " ach.ChartType =" $graph[$chart_type ] ";" NL;
      eval $chart_name cat($sheet_name,"_chart");
      putq " ach.Name=" $chart_name ";" NL;
      putl;

      trigger pivot_chartoptions;

       done;
     done;
   done;
 done;
done;


end;


/************************************************/
/* Generates VBA from options passed to create  */
/* Excel options                                */
/************************************************/

define event excelopt;

do / if cmp($sheet_interval,"none") and ^$worksheet_location;
    put " sheet.Cells( sheet.UsedRange.Rows.Count+2,1).Activate();" NL;
else / if $worksheet_location;
    put " sheet.Cells(" $worksheet_location ").Activate();" NL;
else / if $update_range;
    put " sheet.Cells(" $update_range ").Activate();" NL /if $update_range;
else;
    put " sheet.Cells(1,1).Activate();" NL;
done;


   put " var thisrow=sheet.UsedRange.Rows.Count+2;" NL;

   do / if ^any($worksheet_template,$update_range);
     put " sheet.Paste();" NL;
   else;
     put " sheet.PasteSpecial(Format=0,1,1,1,1,1,NoHTMLFormatting=1);" NL;
   done;

     put " sheet.PageSetup.Orientation=2;" NL /if cmp( $excel_orientation,"landscape");
     put " sheet.PageSetup.Zoom=" $excel_scale ";" NL /if $excel_scale;
     putq " sheet.PageSetup.CenterHeader=" $print_header ";" NL /if $printer_header;
     putq " sheet.PageSetup.CenterFooter=" $print_footer ";" NL /if $printer_footer;


   do /if $auto_format;

   /* Add sheet_interval */
   do / if contains($auto_format,"light") or contains($auto_format,"medium") or contains($auto_format,"dark");
      putlog "2007 style selected";
      put " if (xl.Version > 11) {" NL;
      eval $tblname cat('Table',$test_count);
      do / if ^any($worksheet_location,$sheet_interval);

        putq " sheet.ListObjects.Add(1,sheet.Range(""A1"").CurrentRegion," $tblname ");" NL;
        putq " sheet.ListObjects(" $tblname ").TableStyle = " $excel_format[$auto_format] ";" NL;

     else / if $worksheet_location;

        put " sheet.ListObjects.Add(1,sheet.Cells(" $worksheet_location ").CurrentRegion," """" $tblname """" ");" NL;
        putq " sheet.ListObjects(" $tblname ").TableStyle = " $excel_format[$auto_format] ";" NL;

     else / if cmp($sheet_interval,"none");
        putq " sheet.ListObjects.Add(1,sheet.Cells(sheet.UsedRange.Rows.Count,1 )," compress($sheet_name,"_") ");" NL;
        putq " sheet.ListObjects(" $tblname ").TableStyle = " $excel_format[$auto_format] ";" NL;
     done;
     put "}" NL;

  else;
    do / if ^$worksheet_location;
       put " var newformat=sheet.Range(""A1"");" NL;
       put " newformat.Autoformat(" $excel_format[$auto_format ] ");" NL /if $excel_format[$auto_format];
     else;
       put " var newformat=sheet.Cells(" $worksheet_location ");" NL;
       put " newformat.Autoformat(" $excel_format[$auto_format ] ");" NL /if $excel_format[$auto_format];
    done;
  done;
 done;

   do /if $options["AUTO_FORMAT_SELECT"];
      put " var newformat=sheet.Range(""A1"");" NL;
      put " newformat.Autoformat(val);" NL;
   done;


   do /if exists( $excel_autofilter);

      do /if cmp( $excel_autofilter, "yes");
        do / if ^$worksheet_location;
          put " oRng = sheet.Cells(1,sheet.UsedRange.Columns.Count);" NL;
        else;
          put " oRng = sheet.Cells(" $worksheet_location ",sheet.UsedRange.Columns.Count);" NL;
        done;

      else;
         eval $rangefil cat("A",$excel_autofilter);
         putq " oRng = sheet.Range(" $rangefil ", ""Z65536"");" NL;
      done;

      put " oRng.AutoFilter;" NL;
   done;


   do /if exists( $excel_frozen_headers);

      do /if cmp( $excel_frozen_headers, "yes");
         put " xl.Range(""A2"").Select;" NL;

      else;
         eval $rangefrez cat("A",$excel_frozen_headers);
         putq " xl.Range(" $rangefrez ").Select;" NL;
      done;

      put " xl.ActiveWindow.FreezePanes = ""True"";" NL;
   done;

   put " var wnb=xl.ActiveWindow;" NL;
   put " wnb.Zoom=" $excel_zoom ";" NL /if $excel_zoom;

   do / if ^any($worksheet_location,$sheet_interval);
      put " sheet.Range(""A1"").CurrentRegion.WrapText = 0;" NL;
      put " sheet.Range(""A1"").CurrentRegion.Borders.Weight=2;" NL;
   else / if $worksheet_location;

      put " sheet.Cells(" $worksheet_location ").CurrentRegion.WrapText = 0;" NL;
      put " sheet.Cells(" $worksheet_location ").CurrentRegion.Borders.Weight=2;" NL;
   else / if cmp($sheet_interval,"none");

      put " sheet.Cells(thisrow,1).CurrentRegion.WrapText = 0;" NL;
      put " sheet.Cells(thisrow,1).CurrentRegion.Borders.Weight=2;" NL;

   else;

      put " sheet.Range(""A1"").CurrentRegion.WrapText = 0;" NL;
      put " sheet.Range(""A1"").CurrentRegion.Borders.Weight=2;" NL;

   done;

   put " sheet.Columns.Autofit;" NL;
   put " sheet.Rows.Autofit;" NL;
   put " xl.Columns(""A:Z"").ColumnWidth=" $excel_default_width ";" NL /if $excel_default_width;
   put " xl.Rows(""1:65536"").RowHeight=" $excel_default_height ";" NL /if $excel_default_height;

   trigger num_lookup / if $number_format;
   put NL;
done;

end;

/************************************************/
/* Adds Pivot table list to the format          */
/************************************************/

define event pivot_format;
     set $piv_format["classic"] "20";
     set $piv_format["none"] "21";
     set $piv_format["report1"] "0";
     set $piv_format["report2"] "1";
     set $piv_format["report3"] "2";
     set $piv_format["report3"] "3";
     set $piv_format["report4"] "4";
     set $piv_format["report5"] "5";
     set $piv_format["report6"] "6";
     set $piv_format["report7"] "7";
     set $piv_format["report9"] "8";
     set $piv_format["report10"] "9";
     set $piv_format["table1"] "10";
     set $piv_format["table2"] "11";
     set $piv_format["table3"] "12";
     set $piv_format["table4"] "13";
     set $piv_format["table5"] "14";
     set $piv_format["table6"] "15";
     set $piv_format["table7"] "16";
     set $piv_format["table8"] "17";
     set $piv_format["table9"] "18";
     set $piv_format["table10"] "19";
     set $piv_format["table20"] "20";
     set $piv_format["light1"] "PivotStyleLight1";
     set $piv_format["light2"] "PivotStyleLight2";
     set $piv_format["light3"] "PivotStyleLight3";
     set $piv_format["light4"] "pivotsheetlight4";
     set $piv_format["light5"] "PivotStyleLight5";
     set $piv_format["light6"] "pivotsheetlight6";
     set $piv_format["light7"] "PivotStyleLight7";
     set $piv_format["light8"] "PivotStyleLight8";
     set $piv_format["light9"] "PivotStyleLight9";
     set $piv_format["light10"] "PivotStyleLight10";
     set $piv_format["light11"] "PivotStyleLight11";
     set $piv_format["light12"] "PivotStyleLight12";
     set $piv_format["light13"] "PivotStyleLight13";
     set $piv_format["medium1"] "PivotStyleMedium1";
     set $piv_format["medium2"] "PivotStyleMedium";
     set $piv_format["medium3"] "PivotStyleMedium3";
     set $piv_format["medium4"] "PivotStyleMedium4";
     set $piv_format["medium5"] "PivotStyleMedium5";
     set $piv_format["medium6"] "PivotStyleMedium6";
     set $piv_format["medium7"] "PivotStyleMedium7";
     set $piv_format["medium8"] "PivotStyleMedium8";
     set $piv_format["medium9"] "PivotStyleMedium9";
     set $piv_format["medium10"] "PivotStyleMedium10";
     set $piv_format["medium11"] "PivotStyleMedium11";
     set $piv_format["medium12"] "PivotStyleMedium12";
     set $piv_format["medium13"] "PivotStyleMedium13";
     set $piv_format["dark1"] "PivotStyleDark1";
     set $piv_format["dark2"] "PivotStyleDark2";
     set $piv_format["dark3"] "PivotStyleDark3";
     set $piv_format["dark4"] "PivotStyleDark4";
     set $piv_format["dark5"] "PivotStyleDark5";
     set $piv_format["dark6"] "PivotStyleDark6";
     set $piv_format["dark7"] "PivotStyleDark7";
     set $piv_format["dark8"] "PivotStyleDark8";
     set $piv_format["dark9"] "PivotStyleDark9";
     set $piv_format["dark10"] "PivotStyleDark10";
     set $piv_format["dark11"] "PivotStyleDark11";
     set $piv_format["dark12"] "PivotStyleDark12";
     set $piv_format["dark13"] "PivotStyleDark13";

     set $pivot_format lowcase($pivot_format);

 end;

 /* creates pivot tables from existing file */
define event pivot_tables;

   do /if $ptsource_range;

      set $testing_ptsource scan($ptsource_range,$countx,"|") / if $ptsource_range;
      set $testing_ptdest scan($ptdest_range,$countx,"|")     / if $testing_ptdest;

    /* Add Sheets next to worksheet */
    do / if cmp($options['PIVOT_SERIES'],"yes");
       put " wb.Worksheets.Add(after=wb.Sheets(wb.Sheets.Count));" NL / ^exist($ptdest_range);
    else;
      put " wb.Worksheets.Add(after=" $sheet_name ");" NL / ^exist($ptdest_range);
    done;

      put " var pws = wb.ActiveSheet;" NL;
      put " pws.Name=" $pivotn ";" NL /if ^exist( $ptdest_range);
      putq " var pvtTable = pws.PivotTableWizard(1, varSource=sheet.Range(" $testing_ptsource;
      putq ")";
      putq ",TableDestination=sheet.Range(" $testing_ptdest ")" /if $ptdest_range;
      put ");" NL;
   else;

      set $testing_ptsource scan($ptsource_range,$countx,"|")/ if $ptsource_range;
      set $testing_ptdest scan($ptdest_range,$countx,"|") / if $ptdest_range;

   do / if cmp($options['PIVOT_SERIES'],"yes");

      put " wb.Worksheets.Add(after=wb.Sheets(wb.Sheets.Count));" NL / ^exist($ptdest_range);
      put " var pws = wb.ActiveSheet;" NL;
      eval $epivot_name cat($sheet_name,"_pivot_",$countx) ;
      putq  " var pvtTable = pws.PivotTableWizard(1, varSource=wb.sheets(" $sheet_name ").UsedRange)" NL;

   else;

      putq " wb.Worksheets.Add(after=wb.Sheets(" scan($sheet_name,$countx) "));" NL / ^exist($ptdest_range);
      put " var pws = wb.ActiveSheet;" NL;
      eval $epivot_name cat(scan($sheet_name,$countx),"_pivot") ;
      putq  " var pvtTable = pws.PivotTableWizard(1, varSource=wb.sheets(" scan($sheet_name,$countx) ").UsedRange)" NL;

   done;
      putq ",TableDestination=sheet.Range(" $testing_ptdest ");" NL /if $ptdest_range;

  done; /* Check to see if this is needed */

      putq " pws.Name=" $epivot_name ";" NL /if ^exist( $ptdest_range);
      put NL;
 done;


do /if $pivotrow;

      set $testing_row scan($pivotrow,$countx,"|") ;
      set $testing_rowfmt scan($pivotrow_fmt,$countx,"|") / if $pivotrow_fmt;

    do / if !cmp($testing_row," ");
      do /if index($testing_row, ",");
         set $pivotrow_value scan($testing_row,1,",");
         eval $pivcount 1;

         do /while ^cmp( $pivotrow_value, " ");
            set $p_row[] strip($pivotrow_value);
            eval $pivcount $pivcount +1;
            set $pivotrow_value scan($testing_row,$pivcount,",");
         done;


      else;
         set $p_row[] strip($testing_row);
      done;

      iterate $p_row;

      do /while _value_;
        eval $match _value_;
        eval $re substr($match,1);
        eval $re verify($re,"0123456789");

        do / if $re=1;
           putq " pvtTable.PivotFields(" upcase(_value_) ").Orientation = 1;" NL / if !cmp(_value_," ");
           putq " pvtTable.PivotFields(" upcase(_value_) ").Numberformat=" "" $testing_rowfmt "" ";" NL / if $testing_rowfmt;
               putq " pvtTable.PivotFields(" upcase(_value_) ").Subtotals(1) = 0;" NL / if cmp($options['PIVOT_SUBTOTAL'],"no");
        else;
           put " pvtTable.PivotFields(" _value_ ").Orientation = 1;" NL;
           put " pvtTable.PivotFields(" _value_ ").Numberformat=" """" $testing_rowfmt """" ";" NL / if $testing_rowfmt;
        done;

        next $p_row;
      done;

   done;
done;


   do /if $pivotcol;

     set $testing_col scan($pivotcol,$countx,"|");
     set $testing_colfmt scan($pivotcol_fmt,$countx,"|") / if $pivotcol_fmt;

    do / if !cmp($testing_col," ");
      do /if index($pivotcol, ",");
         set $pivotcol_value scan($testing_col,1,",");
         eval $pivcountc 1;

         do /while ^cmp( $pivotcol_value, " ");
            set $p_col[] strip($pivotcol_value);
            eval $pivcountc $pivcountc +1;
            set $pivotcol_value scan($testing_col,$pivcountc,",");
         done;


      else;
         set $p_col[] strip($testing_col);
      done;

      iterate $p_col;

      do /while _value_;

        eval $match _value_;
        eval $re substr($match,1);
        eval $re verify($re,"0123456789");

        do / if $re=1;
          putq " pvtTable.PivotFields(" upcase(_value_) ").Orientation = 2;" NL;
          putq " pvtTable.PivotFields(" upcase(_value_) ").Numberformat=" "" $testing_colfmt "" ";" NL / if $testing_colfmt;
              putq " pvtTable.PivotFields(" upcase(_value_) ").Subtotals(1) = 0;" NL / if cmp($options['PIVOT_SUBTOTAL'],"no");
        else;
          put " pvtTable.PivotFields(" _value_ ").Orientation = 2;" NL;
          put " pvtTable.PivotFields(" _value_ ").Numberformat=" """" $testing_colfmt """" ";" NL / if $testing_colfmt;
        done;
      next $p_col;
      done;

   done;
done;

  do /if $pivotdata;

       set $testing_data scan($pivotdata,$countx,"|");
       set $testing_datafmt scan($pivotdata_fmt,$countx,"|") / if $pivotdata_fmt;
       set $testing_stats scan($pivotdata_stats,$countx,"|") / if $pivotdata_stats;
       set $testing_calc scan($pivotcalc,$countx,"|") / if $pivotcalc;
       set $p_datas[] scan($testing_stats,1);

      do / if !cmp($testing_data," ");
        do /if index($testing_data, ",");
         set $pivotdata_value scan($testing_data,1,",");

         eval $pivcountd 1;

         do /while ^cmp( $pivotdata_value, " ");
            set $p_data[] strip($pivotdata_value);

            eval $pivcountd $pivcountd +1;
            set $pivotdata_value scan($testing_data,$pivcountd,",");

         done;


      else;
         set $p_data[] strip($testing_data);

      done;

      eval $pivot_cnt 1;
      iterate $p_data;

       do /while _value_;
        eval $pivot_cnt $pivot_cnt+1;
        eval $match $pivotdata;
        eval $re substr($match,1);
        eval $re verify($re,"0123456789");

        do / if $re=1;
           putq " pvtTable.PivotFields(" upcase(_value_) ").Orientation = 4;" NL;
               putq " pvtTable.PivotFields(" upcase(_value_) ").Subtotals(1) = 0;" NL / if cmp($options['PIVOT_SUBTOTAL'],"no");
           set $pivot_funcname strip($testing_stats) ;

           do / if $testing_stats;

                set $pivot_funcname strip($testing_stats) ;
                eval $stat_name cat($pivot_funcname," OF ",_value_);
                eval $numberf_name cat("Sum Of ",_value_);
                set $testing_stats strip($testing_stats);

             do / if $testing_stats;

               do / if cmp($testing_stats,"Average");
                  putq " pvtTable.PivotFields(" upcase($numberf_name)  ").Function=" "" -4106 "" ";" NL ;
               else / if cmp($testing_stats,"Sum");
                  putq " pvtTable.PivotFields(" upcase($numberf_name) ").Function=" "" -4157 "" ";" NL;
               else / if cmp($testing_stats,"Count");
                  putq " pvtTable.PivotFields(" upcase($numberf_name)  ").Function=" "" -4112 "" ";" NL;
               else / if cmp($testing_stats,"Max");
                  putq " pvtTable.PivotFields(" upcase($numberf_name) ").Function=" "" -4136 "" ";" NL;
               else / if cmp($testing_stats,"Min");
                  putq " pvtTable.PivotFields(" upcase($numberf_name) ").Function=" "" -4139 "" ";" NL;
               else / if cmp($testing_stats,"CountNums");
                  putq " pvtTable.PivotFields(" upcase($numberf_name) ").Function=" "" -4113 "" ";" NL;
               else / if cmp($testing_stats,"Product");
                  putq " pvtTable.PivotFields(" upcase($numberf_name) ").Function=" "" -4149 "" ";" NL;
               else / if cmp($testing_stats,"StdDev");
                  putq " pvtTable.PivotFields(" upcase($numberf_name) ").Function=" "" -4155 "" ";" NL;
               else / if cmp($testing_stats,"StdDevP");
                  putq " pvtTable.PivotFields(" upcase($numberf_name) ").Function=" "" -4156 "" ";" NL;
               else / if cmp($testing_stats,"Var");
                  putq " pvtTable.PivotFields(" upcase($numberf_name) ").Function=" "" -4164 "" ";" NL;
               else / if cmp($testing_stats,"Var");
                  putq " pvtTable.PivotFields(" upcase($numberf_name) ").Function=" "" -4165 "" ";" NL;

               done;
            done;
         done;

        do / if $testing_datafmt;

          set $eee scan($testing_datafmt,$pivot_cnt,"~") /if $testing_datafmt;


              do / if $testing_stats;
                  putq " pvtTable.PivotFields(" upcase($stat_name) ").Numberformat=" "" $eee "" ";" NL;
              else;
                  putq " pvtTable.PivotFields(" "Sum Of " ").Numberformat=" "" $eee "" ";" NL;
              done;
         done;

         do / if $testing_calc;

              do / if cmp($testing_calc,"row");
                   putq " pvtTable.PivotFields(" upcase($stat_name) ").Calculation=" "" 7 "" ";" NL;
                 else / if cmp($testing_calc,"column");
                   putq " pvtTable.PivotFields(" upcase($stat_name) ").Calculation=" "" 8 "" ";" NL;
                 else / if cmp($testing_calc,"total");
                    putq " pvtTable.PivotFields(" upcase($stat_name) ").Calculation=" "" 9 "" ";" NL;
                 else / if cmp($testing_calc,"differencefrom");
                   putq " pvtTable.PivotFields(" upcase($stat_name) ").Calculation=" "" 2 "" ";" NL;
                 else / if cmp($testing_calc,"percentdifferencefrom");
                    putq " pvtTable.PivotFields(" upcase($stat_name) ").Calculation=" "" 4 "" ";" NL;
                 else / if cmp($testing_calc,"percentof");
                   putq " pvtTable.PivotFields(" upcase($stat_name) ").Calculation=" "" 3 "" ";" NL;
                 else / if cmp($testing_calc,"runningtotal");
                    putq " pvtTable.PivotFields(" upcase($stat_name) ").Calculation=" "" 5 "" ";" NL;
                done;
             done;


        else;
           put " pvtTable.PivotFields(" _value_ ").Orientation = 4;" NL;
           put " pvtTable.PivotFields(" _value_ ").Numberformat=" """" $pivotdata_fmt """" ";" NL / if $pivotadata_fmt;
        done;

     next $p_data;

   done;
 done;
done;

do /if $pivotpage;

     set $testing_page scan($pivotpage,$countx,"|");
     set $testing_pagefmt scan($pivotpage_fmt,$countx,"|") / if $pivotpage_fmt;

    do / if !cmp($testing_page," ");
      do /if index($pivotpage, ",");
         set $pivotpage_value scan($testing_page,1,",");
         eval $pivcountp 1;

         do /while ^cmp( $pivotpage_value, " ");
            set $p_page[] strip($pivotpage_value);
            eval $pivcountp $pivcountp +1;
            set $pivotpage_value scan($testing_page,$pivcountp,",");
         done;


      else;
         set $p_page[] strip($testing_page);
      done;

      iterate $p_page;

      do /while _value_;

        eval $match _value_;
        eval $re substr($match,1);
        eval $re verify($re,"0123456789");

        do / if $re=1;
          putq " pvtTable.PivotFields(" upcase(_value_) ").Orientation = 3;" NL;
          putq " pvtTable.PivotFields(" upcase(_value_) ").Numberformat=" "" $testing_pagefmt "" ";" NL / if $testing_pagefmt;
              putq " pvtTable.PivotFields(" upcase(_value_) ").Subtotals(1) = 0;" NL / if cmp($options['PIVOT_SUBTOTAL'],"no");
        else;
          put " pvtTable.PivotFields(" _value_ ").Orientation = 3;" NL;
          put " pvtTable.PivotFields(" _value_ ").Numberformat=" """" $testing_pagefmt """" ";" NL / if $testing_pagefmt;
        done;

         next $p_page;
      done;

   done;
 done;

putl;
trigger excelchart / if $pivotcharts;

unset $p_row;
unset $p_col;
unset $p_data;
unset $p_page;


end;


define event pivot_tables_single;

 do /if $ptsource_range;
      Putl;
      eval $pivotn quote(cat($sheet_name,"_pivot"));
      put " wb.Worksheets.Add(after=wb.Sheets(wb.Sheets.Count));" NL / ^exist($ptdest_range);
      put " var pws = wb.ActiveSheet;" NL;
      put " pws.Name=" $pivotn ";" NL /if ^exist( $ptdest_range);
      putq " var pvtTable = pws.PivotTableWizard(1, varSource=sheet.Range(" $ptsource_range;
      putq ")";
      putq ",TableDestination=sheet.Range(" $ptdest_range ")" /if $ptdest_range;

      put  ");" NL / if ^exist($pivot_format,$format_condition);


      do / if any($pivot_format,$format_condition);

        putq  "," $id ",1,1" ");" NL / if $pivot_format;
        putq " var ptformat=pws.PivotTables(" $id ");" NL / if $pivot_format;
        putq " var tblname=pws.PivotTables(" $id ");" NL / if $format_condition;

      done;

   else;
      eval $pivotn quote(cat($sheet_name,"_pivot"));
      putl;
      put " wb.Worksheets.Add(after=wb.Sheets(wb.Sheets.Count));" NL / ^exist($ptdest_range);
      put " var pws = wb.ActiveSheet;" NL;
      put " pws.Name=" $pivotn ";" NL /if ^exist( $ptdest_range);

  do / if ^$worksheet_location;
      putq  " var pvtTable = pws.PivotTableWizard(1, varSource=wb.sheets(" $sheet_name ").Range(""A1"").CurrentRegion";
  else;
       put  " var pvtTable = pws.PivotTableWizard(1, varSource=wb.sheets(" """" $sheet_name """" ").Cells(" $worksheet_location ").CurrentRegion";
  done;

  /* Fix the hard coded range to work with worksheet location */

      putq ",TableDestination=sheet.Range(" $ptdest_range ")" /if $ptdest_range;

    do / if any($pivot_format,$pivot_grandtotal,$format_condition);
        do / if any($pivot_format,$format_condition) and ^exist($pivot_grandtotal);
         put " ,pws.Range(""A1"")," $pivotn ",1,1";
        else / if cmp($pivot_grandtotal,"no");
           put " ,pws.Range(""A1"")," $pivotn ",0,0";
        done;
      done;

      do / if !exist($pivotdata);
         do / if !any($pivot_format,$format_condition,$pivot_grandtotal);
           put " ,pws.Range(""A1"")," $pivotn ",1,1";
         done;
   done;

        put ");" NL;
      putq " var ptformat=pws.PivotTables(" dequote($Pivotn) ");" NL / if $pivot_format;
      putq " var tblname=pws.PivotTables(" dequote($Pivotn) ");" NL / if $addfield;
   done;


   trigger add_datafield / $addfield;

   do /if $pivotrow;

      do /if index($pivotrow, ",");
         set $pivotrow_value scan($pivotrow,1,",");
         eval $pivcount 1;

         do /while ^cmp( $pivotrow_value, " ");
            set $p_row[] strip($pivotrow_value);
            eval $pivcount $pivcount +1;
            set $pivotrow_value scan($pivotrow,$pivcount,",");
         done;


      else;
         set $p_row[] strip($pivotrow);
      done;

      iterate $p_row;


    do /while _value_;

      eval $match $pivotrow;
      eval $re substr($match,1);
      eval $re verify($re,"0123456789");

        do / if $re=1;
           putq " pvtTable.PivotFields(" upcase(_value_) ").Orientation = 1;" NL;
           putq " pvtTable.PivotFields(" upcase(_value_) ").Numberformat=" "" $pivotrow_fmt "" ";" NL / if $pivotrow_fmt;
           putq " pvtTable.PivotFields(" upcase(_value_) ").Subtotals(1) = 0;" NL / if cmp($options['PIVOT_SUBTOTAL'],"no");
        else;
           put " pvtTable.PivotFields(" _value_ ").Orientation = 1;" NL;
           put " pvtTable.PivotFields(" _value_ ").Numberformat=" """" $pivotrow_fmt """" ";" NL / if $pivotrow_fmt;
        done;

      next $p_row;

   done;
done;


 do /if $pivotcol;

         do /if index($pivotcol, ",");
           set $pivotcol_value scan($pivotcol,1,",");
           eval $pivcountc 1;

         do /while ^cmp( $pivotcol_value, " ");
            set $p_col[] strip($pivotcol_value);
            eval $pivcountc $pivcountc +1;
            set $pivotcol_value scan($pivotcol,$pivcountc,",");
         done;


      else;
         set $p_col[] strip($pivotcol);
      done;

      iterate $p_col;

       do /while _value_;

       eval $match $pivotcol;
       eval $re substr($match,1);
       eval $re verify($re,"0123456789");

        do / if $re=1;
          putq " pvtTable.PivotFields(" upcase(_value_) ").Orientation = 2;" NL;
          putq " pvtTable.PivotFields(" upcase(_value_) ").Numberformat=" "" $pivotcol_fmt "" ";" NL / if $pivotcol_fmt;
              putq " pvtTable.PivotFields(" upcase(_value_) ").Subtotals(1) = 0;" NL / if cmp($options['PIVOT_SUBTOTAL'],"no");
        else;
          put " pvtTable.PivotFields(" _value_ ").Orientation = 2;" NL;
          put " pvtTable.PivotFields(" _value_ ").Numberformat=" """" $pivotcol_fmt """" ";" NL / if $pivotcol_fmt;
        done;

    next $p_col;

   done;
 done;


 do /if $pivotdata;

        do /if index($pivotdata, ",");
         set $pivotdata_value scan($pivotdata,1,",");
         set $pivotdata_fvalue scan($pivotdata_fmt,1,"~") /   if $pivotdata_fmt;
         set $pivotdata_svalue scan($pivotdata_stats,1,",") / if $pivotdata_stats;
         set $pivotdata_cvalue scan($pivotdata_caption,1,",") / if $pivotdata_caption;
         set $pivotdata_calcvalue scan($pivotcalc,1,",") / if $pivotcalc;



         set $p_dataf[] $pivotdata_fvalue / if $pivotdata_fmt;
         set $p_datas[] $pivotdata_svalue / if $pivotdata_stats;
         set $p_datac[] $pivotdata_cvalue / if $pivotdata_caption;
         set $p_datacalc[] $pivotdata_calcvalue / if $pivotcalc;


         eval $pivcountd 1;

         do /while ^cmp( $pivotdata_value, " ");
            set $p_data[] strip($pivotdata_value);
            set $p_dataf[] $pivotdata_fvalue / if $pivotdata_fmt;
            set $p_datas[] $pivotdata_svalue / if $pivotdata_stats;
            set $p_datac[] $pivotdata_cvalue / if $pivotdata_caption;
            set $p_datacalc[] $pivotdata_calcvalue / if $pivotcalc;

            eval $pivcountd $pivcountd +1;
            set $pivotdata_value scan($pivotdata,$pivcountd,",");
            set $pivotdata_fvalue scan($pivotdata_fmt,$pivcountd,"~") /if $pivotdata_fmt;
            set $pivotdata_svalue scan($pivotdata_stats,$pivcountd,",") /if $pivotdata_stats;
            set $pivotdata_cvalue scan($pivotdata_caption,$pivcountd,",") /if $pivotdata_caption;
            set $pivotdata_calcvalue scan($pivotcalc,$pivcountd,",") /if $pivotcalc;

         done;


      else;
         set $p_data[] strip($pivotdata);

      done;

      eval $pivot_cnt 1;
      iterate $p_data;

       do /while _value_;
        eval $pivot_cnt $pivot_cnt+1;
        eval $match $pivotdata;
        eval $re substr($match,1);
        eval $re verify($re,"0123456789");

        do / if $re=1;
           putq " pvtTable.PivotFields(" upcase(_value_) ").Orientation = 4;" NL;
               putq " pvtTable.PivotFields(" upcase(_value_) ").Subtotals(1) = 0;" NL / if cmp($options['PIVOT_SUBTOTAL'],"no");

           do / if $pivotdata_stats;

             do / if $pivotdata_caption;
                do / if index($pivotdata_caption,",");
                   eval $stat_caption cat($p_datas[$pivot_cnt]," Of ",_value_);
                else;
                   eval $stat_caption cat($pivotdata_stats," Of ",_value_);
                done;
             done;

               set $stat_prefix  "Sum Of ";
               /*eval $stat_caption cat($p_datas[$pivot_cnt],"Of",_value_);*/
               eval $stat_name cat($stat_prefix,_value_);

             do / if index($pivotdata_stats,",");
              /* If caption not working this needs to be a eval */
              /* eval  $stat_caption cat($p_datas[$pivot_cnt]," Of ",_value_);*/

               do / if cmp($p_datas[$pivot_cnt],"Average");
                  putq " pvtTable.PivotFields(" upcase($stat_name) ").Function=" "" -4106 "" ";" NL ;
               else / if cmp($p_datas[$pivot_cnt],"Sum");
                  putq " pvtTable.PivotFields(" upcase($stat_name) ").Function=" "" -4157 "" ";" NL;
               else / if cmp($p_datas[$pivot_cnt],"Count");
                  putq " pvtTable.PivotFields(" upcase($stat_name) ").Function=" "" -4112 "" ";" NL;
               else / if cmp($p_datas[$pivot_cnt],"Max");
                  putq " pvtTable.PivotFields(" upcase($stat_name) ").Function=" "" -4136 "" ";" NL;
               else / if cmp($p_datas[$pivot_cnt],"Min");
                  putq " pvtTable.PivotFields(" upcase($stat_name) ").Function=" "" -4139 "" ";" NL;
               else / if cmp($p_datas[$pivot_cnt],"CountNums");
                  putq " pvtTable.PivotFields(" upcase($stat_name) ").Function=" "" -4113 "" ";" NL;
               else / if cmp($p_datas[$pivot_cnt],"Product");
                  putq " pvtTable.PivotFields(" upcase($stat_name) ").Function=" "" -4149 "" ";" NL;
               else / if cmp($p_datas[$pivot_cnt],"StdDev");
                  putq " pvtTable.PivotFields(" upcase($stat_name) ").Function=" "" -4155 "" ";" NL;
               else / if cmp($p_datas[$pivot_cnt],"StdDevP");
                  putq " pvtTable.PivotFields(" upcase($stat_name) ").Function=" "" -4156 "" ";" NL;
               else / if cmp($p_datas[$pivot_cnt],"Var");
                  putq " pvtTable.PivotFields(" upcase($stat_name) ").Function=" "" -4164 "" ";" NL;
               else / if cmp($p_datas[$pivot_cnt],"VarP");
                  putq " pvtTable.PivotFields(" upcase($stat_name) ").Function=" "" -4165 "" ";" NL;

            done;
           else;
           set $stat_caption cat($pivotdata_caption,"Of",_value_) / if $pivotdata_caption;

           do / if cmp($pivotdata_stats,"Average");
                  putq " pvtTable.PivotFields(" upcase($stat_name) ").Function=" "" -4106 "" ";" NL ;
            else / if cmp($pivotdata_stats,"Sum");
                 putq " pvtTable.PivotFields(" upcase($stat_name) ").Function=" "" -4157 "" ";" NL;
            else / if cmp($pivotdata_stats,"Count");
                  putq " pvtTable.PivotFields(" upcase($stat_name) ").Function=" "" -4112 "" ";" NL;
            else / if cmp($pivotdata_stats,"Max");
                  putq " pvtTable.PivotFields(" upcase($stat_name) ").Function=" "" -4136 "" ";" NL;
            else / if cmp($pivotdata_stats,"Min");
                  putq " pvtTable.PivotFields(" upcase($stat_name) ").Function=" "" -4139 "" ";" NL;
            else / if cmp($pivotdata_stats,"CountNums");
                  putq " pvtTable.PivotFields(" upcase($stat_name) ").Function=" "" -4113 "" ";" NL;
            else / if cmp($pivotdata_stats,"Product");
                  putq " pvtTable.PivotFields(" upcase($stat_name) ").Function=" "" -4149 "" ";" NL;
            else / if cmp($pivotdata_stats,"StdDev");
                  putq " pvtTable.PivotFields(" upcase($stat_name) ").Function=" "" -4155 "" ";" NL;
            else / if cmp($pivotdata_stats,"StdDevP");
                  putq " pvtTable.PivotFields(" upcase($stat_name) ").Function=" "" -4156 "" ";" NL;
            else / if cmp($pivotdata_stats,"Var");
                  putq " pvtTable.PivotFields(" upcase($stat_name) ").Function=" "" -4164 "" ";" NL;
            else / if cmp($pivotdata_stats,"VarP");
                 putq " pvtTable.PivotFields(" upcase($stat_name) ").Function=" "" -4165 "" ";" NL;
            done;
         done;
       done;



       do / if $pivotdata_fmt;
           set $pivot_single index($pivotdata_fmt,"~");

           do / if $pivotdata_stats;
              do / if ^cmp($pivot_single,"0");
                 eval $statfmt_prefix upcase(cat($p_datas[$pivot_cnt]," Of ",_value_));
               else;
                  eval $statfmt_prefix upcase(cat($pivotdata_stats," Of ",_value_));
               done;

             do / if cmp($pivot_single,"0");
                putq " pvtTable.PivotFields(" upcase($statfmt_prefix) ").Numberformat=" "" $pivotdata_fmt "" ";" NL;
             else;
               putq " pvtTable.PivotFields(" upcase($statfmt_prefix) ").Numberformat=" "" $p_dataf[$pivot_cnt] "" ";" NL;
             done;

          else;

          eval $statfmt_prefix upcase(cat("Sum Of ",_value_));
          do / if cmp($pivot_single,"0");
               putq " pvtTable.PivotFields(" upcase($statfmt_prefix) ").Numberformat=" "" $pivotdata_fmt "" ";" NL;
             else;
              putq " pvtTable.PivotFields(" upcase($statfmt_prefix) ").Numberformat=" "" $p_dataf[$pivot_cnt] "" ";" NL;
          done;
      done;
     done;


      do / if $pivotcalc;

       set $pivot_calc["row" ] "6";
       set $pivot_calc["column" ] "7";
       set $pivot_calc["total" ] "8";
       set $pivot_calc["index" ] "9";
       set $pivot_calc["differencefrom" ] "2";
       set $pivot_calc["percentdifferencefrom" ] "4";
       set $pivot_calc["percentof" ] "3";
       set $pivot_calc["runningtotal"] "5";

       do/ if ^$pivotdata_stats;
          do / if index($pivotdata,",");
              put " pvtTable.PivotFields(""Sum Of " _value_ """ ).Calculation=" """" $pivot_calc[$pivotcalc] """" ";" NL  /  if $p_datac[$pivot_cnt];
          else;
              put " pvtTable.PivotFields(""Sum Of "  _value_ """).Calculation=" """" $pivot_calc[$pivotcalc] """" ";" NL  /  if $pivotcalc;
       done;

       else;


         do / if index($pivotdata,",") and index($pivotdata_stats,",");
            /* putlog "multi vars and stats"; */

         /***********************************************************************/
         /* Create a list to scan for the field pivot calc. Currently this is a */
         /* single argument.                                                    */
         /***********************************************************************/

           do / if cmp($p_datacalc[$pivot_cnt],"row");
               put  " pvtTable.PivotFields(" """" upcase($p_datas[$pivot_cnt]) " Of "  upcase(_value_)  """" ").Calculation = 6;" NL;
            else / if cmp($p_datacalc[$pivot_cnt],"column");
               put  " pvtTable.PivotFields(" """" upcase($p_datas[$pivot_cnt]) " Of " upcase(_value_) """" ").Calculation = 7;" NL;
            else / if cmp($p_datacalc[$pivot_cnt],"total");
               put  " pvtTable.PivotFields(" """" upcase($p_datas[$pivot_cnt]) " Of " upcase(_value_) """" ").Calculation = 8;" NL;
            else / if cmp($p_datacalc[$pivot_cnt],"index");
               put  " pvtTable.PivotFields(" """" upcase($p_datas[$pivot_cnt]) " Of " upcase(_value_) """" ").Calculation = 9;" NL;
            else / if cmp($p_datacalc[$pivot_cnt],"differencefrom");
               put  " pvtTable.PivotFields(" """" upcase($p_datas[$pivot_cnt]) " Of " upcase(_value_) """" ").Calculation = 2;" NL;
            else / if cmp($p_datacalc[$pivot_cnt],"percentdifferencefrom");
               put  " pvtTable.PivotFields(" """" upcase($p_datas[$pivot_cnt]) " Of " upcase(_value_) """" ").Calculation = 4;" NL;
            else / if cmp($p_datacalc[$pivot_cnt],"percentof");
               put  " pvtTable.PivotFields(" """" upcase($p_datas[$pivot_cnt]) " Of " upcase(_value_) """" ").Calculation = 3;" NL;
            else / if cmp($p_datacalc[$pivot_cnt],"runningtotal");
               put  " pvtTable.PivotFields(" """" upcase($p_datas[$pivot_cnt]) " Of " upcase(_value_) """" ").Calculation = 5;" NL;
          done;

         else;
            /* putlog "single vars"; */

            do / if cmp($pivotcalc,"row");
               put  " pvtTable.PivotFields(" """" upcase($pivotdata_stats) " Of " upcase(_value_)  """" ").Calculation = 6;" NL;
            else / if cmp($pivotcalc,"column");
               put  " pvtTable.PivotFields(" """" upcase($pivotdata_stats) " Of " upcase(_value_) """" ").Calculation = 7;" NL;
            else / if cmp($pivotcalc,"total");
               put  " pvtTable.PivotFields(" """" upcase($pivotdata_stats) " Of " upcase(_value_) """" ").Calculation = 8;" NL;
            else / if cmp($pivotcalc,"index");
               put  " pvtTable.PivotFields(" """" upcase($pivotdata_stats) " Of " upcase(_value_) """" ").Calculation = 9;" NL;
            else / if cmp($pivotcalc,"differencefrom");
               put  " pvtTable.PivotFields(" """" upcase($pivotdata_stats) " Of " upcase(_value_) """" ").Calculation = 2;" NL;
            else / if cmp($pivotcalc,"percentdifferencefrom");
               put  " pvtTable.PivotFields(" """" upcase($pivotdata_stats) " Of " upcase(_value_) """" ").Calculation = 4;" NL;
            else / if cmp($pivotcalc,"percentof");
               put  " pvtTable.PivotFields(" """" upcase($pivotdata_stats) " Of " upcase(_value_) """" ").Calculation = 3;" NL;
            else / if cmp($pivotcalc,"runningtotal");
               put  " pvtTable.PivotFields(" """" upcase($pivotdata_stats) " Of " upcase(_value_) """" ").Calculation = 5;" NL;
            done;
          done;
       done;
   done;

     do / if $pivotdata_caption;
           do/ if !$pivotdata_stats;
                do / if index($pivotdata,",");
                  put " pvtTable.PivotFields(""Sum Of " _value_ """ ).Caption=" """" $p_datac[$pivot_cnt] """" ";" NL  /  if $p_datac[$pivot_cnt];
            else;
                  put " pvtTable.PivotFields(""Sum Of "  _value_ """).Caption=" """" $pivotdata_caption """" ";" NL  /  if $pivotdata_caption;
            done;

        else;

        do / if index($pivotdata_stats,",");
           do / if cmp($p_datas[$pivot_cnt],"Average");
             putq " pvtTable.PivotFields(" upcase($stat_caption) ").Caption=" "" $p_datac[$pivot_cnt] "" ";" NL  /  if $p_datac[$pivot_cnt];
         else / if cmp($p_datas[$pivot_cnt],"Sum");
             putq " pvtTable.PivotFields(" upcase($stat_caption) ").Caption=" "" $p_datac[$pivot_cnt] "" ";" NL  /  if $p_datac[$pivot_cnt];
         else / if cmp($p_datas[$pivot_cnt],"Count");
             putq " pvtTable.PivotFields(" upcase($stat_caption) ").Caption=" "" $p_datac[$pivot_cnt] "" ";" NL  /  if $p_datac[$pivot_cnt];
         else / if cmp($p_datas[$pivot_cnt],"Max");
             putq " pvtTable.PivotFields(" upcase($stat_caption) ").Caption=" "" $p_datac[$pivot_cnt] "" ";" NL  /  if $p_datac[$pivot_cnt];
         else / if cmp($p_datas[$pivot_cnt],"Min");
             putq " pvtTable.PivotFields(" upcase($stat_caption) ").Caption=" "" $p_datac[$pivot_cnt] "" ";" NL  /  if $p_datac[$pivot_cnt];
         else / if cmp($p_datas[$pivot_cnt],"CountNums");
             putq " pvtTable.PivotFields(" upcase($stat_caption) ").Caption=" "" $p_datac[$pivot_cnt] "" ";" NL  /  if $p_datac[$pivot_cnt];
         else / if cmp($p_datas[$pivot_cnt],"Product");
              putq " pvtTable.PivotFields(" upcase($stat_caption) ").Caption=" "" $p_datac[$pivot_cnt] "" ";" NL  /  if $p_datac[$pivot_cnt];
         else / if cmp($p_datas[$pivot_cnt],"StdDev");
              putq " pvtTable.PivotFields(" upcase($stat_caption) ").Caption=" "" $p_datac[$pivot_cnt] "" ";" NL  /  if $p_datac[$pivot_cnt];
         else / if cmp($p_datas[$pivot_cnt],"StdDevP");
              putq " pvtTable.PivotFields(" upcase($stat_caption) ").Caption=" "" $p_datac[$pivot_cnt] "" ";" NL  /  if $p_datac[$pivot_cnt];
         else / if cmp($p_datas[$pivot_cnt],"Var");
              putq " pvtTable.PivotFields(" upcase($stat_caption) ").Caption=" "" $p_datac[$pivot_cnt] "" ";" NL  /  if $p_datac[$pivot_cnt];
         else / if cmp($p_datas[$pivot_cnt],"VarP");
              putq " pvtTable.PivotFields(" upcase($stat_caption) ").Caption=" "" $p_datac[$pivot_cnt]  "" ";" NL  /  if $p_datac[$pivot_cnt];
         done;
      else;
          eval $stat_caption cat($pivotdata_caption," Of ",_value_);

           do / if cmp($pivotdata_stats,"Average");
               putq " pvtTable.PivotFields(" upcase($stat_caption) ").Caption=" "" $pivotdata_caption "" ";" NL  / if $pivotdata_caption;
           else / if cmp($pivotdata_stats,"Sum");
               putq " pvtTable.PivotFields(" upcase($stat_caption) ").Caption=" "" $pivotdata_caption "" ";" NL  / if $pivotdata_caption;
           else / if cmp($pivotdata_stats,"Count");
               putq " pvtTable.PivotFields(" upcase($stat_caption) ").Caption=" "" $pivotdata_caption "" ";" NL  / if $pivotdata_caption;
           else / if cmp($pivotdata_stats,"Max");
               putq " pvtTable.PivotFields(" upcase($stat_caption) ").Caption=" "" $pivotdata_caption "" ";" NL  / if $pivotdata_caption;
           else / if cmp($pivotdata_stats,"Min");
               putq " pvtTable.PivotFields(" upcase($stat_caption) ").Caption=" "" $pivotdata_caption "" ";" NL  / if $pivotdata_caption;
           else / if cmp($pivotdata_stats,"CountNums");
               putq " pvtTable.PivotFields(" upcase($stat_caption) ").Caption=" "" $pivotdata_caption "" ";" NL  / if $pivotdata_caption;
           else / if cmp($pivotdata_stats,"Product");
               putq " pvtTable.PivotFields(" upcase($stat_caption) ").Caption=" "" $pivotdata_caption "" ";" NL  / if $pivotdata_caption;
           else / if cmp($pivotdata_stats,"StdDev");
               putq " pvtTable.PivotFields(" upcase($stat_caption) ").Caption=" "" $pivotdata_caption "" ";" NL  / if $pivotdata_caption;
           else / if cmp($pivotdata_stats,"StdDevP");
               putq " pvtTable.PivotFields(" upcase($stat_caption) ").Caption=" "" $pivotdata_caption "" ";" NL  / if $pivotdata_caption;
           else / if cmp($pivotdata_stats,"Var");
               putq " pvtTable.PivotFields(" upcase($stat_caption) ").Caption=" "" $pivotdata_caption "" ";" NL  / if $pivotdata_caption;
           else / if cmp($pivotdata_stats,"VarP");
               putq " pvtTable.PivotFields(" upcase($stat_caption) ").Caption=" "" $pivotdata_caption "" ";" NL  / if $pivotdata_caption;

             done;
            done;
          done;
       done;
     else ;
           put " pvtTable.PivotFields(" _value_ ").Orientation = 4;" NL;
           put " pvtTable.PivotFields(" _value_ ").Numberformat=" """" $pivotdata_fmt """" ";" NL / if $pivotadata_fmt;
        done;

     next $p_data;

   done;
done;

   do /if $pivotpage;
      do /if index($pivotpage, ",");
         /*putlog "we are here";*/
         set $pivotpage_value scan($pivotpage,1,",");
         eval $pivcountp 1;

         do /while ^cmp( $pivotpage_value, " ");
            set $p_page[] strip($pivotpage_value);
            eval $pivcountp $pivcountp +1;
            set $pivotpage_value scan($pivotpage,$pivcountp,",");
         done;

      else;
         set $p_page[] strip($pivotpage);
      done;

      iterate $p_page;

      do /while _value_;

        eval $match $pivotpage;
        eval $re substr($match,1);
        eval $re verify($re,"0123456789");


        do / if $re=1;
           putq " pvtTable.PivotFields(" upcase(_value_) ").Orientation = 3;" NL;
           putq " pvtTable.PivotFields(" upcase(_value_) ").Numberformat=" "" $pivotpage_fmt "" ";" NL / if $pivopage_fmt;
               putq " pvtTable.PivotFields(" upcase(_value_) ").Subtotals(1) = 0;" NL / if cmp($options['PIVOT_SUBTOTAL'],"no");
        else;
           put " pvtTable.PivotFields(" _value_ ").Orientation = 3;" NL;
           put " pvtTable.PivotFields(" _value_ ").Numberformat=" """" $pivoptpage_fmt """" ";" NL / if $pivotpge_fmt;
        done;

     next $p_page;

   done;
  done;

   /* Testing added additional code*/
  do / if contains($pivot_format,"light") or contains($pivot_format,"medium") or contains($pivot_format,"dark");
     trigger pivot_format;
     putlog "2007 PivotTable style selected";
     put " if (xl.Version > 11) {" NL;
     putq " ptformat.TableStyle2 =" $piv_format[$pivot_format] ";" NL;
     put "}" NL;
  else;
    trigger pivot_format;
    putq " ptformat.Format(format=" $piv_format[$pivot_format] ");" NL / if $pivot_format;

  done;
  put " pws.PivotTables(" $pivotn ").DisplayImmediateItems = 1;" NL  / if !exist($pivotdata);
  put " pvtTable.DataPivotField.Orientation=2;" / if cmp($options['PIVOTDATA_TOCOLUMNS'],"yes");
  trigger format_condition / if $format_condition;

  put NL;
  put " pws.Columns.Autofit;" NL;
  put " pws.Rows.Autofit;" NL;

  trigger excelchart / if $pivotcharts;

unset $p_row;
unset $p_col;
unset $p_data;
unset $p_page;


end;


define event add_datafield;

  do /if index($addfield, ",");
     set $addfield_value scan($addfield,1,",");
       eval $addcnt 1;

      do /while ^cmp($addfield_value," ");
         eval $add_value[] strip($addfield_value);
         eval $addcnt $addcnt+1;

         set $addfield_value scan($addfield,$addcnt,",");
      done;

   else;

      set $add_value[] strip($addfield);
   done;

   iterate $add_value;

   do / while _value_;

       eval $equal indexc(_value_,"=");
       eval $fmlaloc $equal-1;
       eval $cfield upcase(substr(_value_,1,$fmlaloc));
       eval $fmla substr(_value_,$equal);

       putq " var addfield=tblname.CalculatedFields().Add(" strip($cfield) "," $fmla ");" NL;
       putlog $cfield $fmla;
    next $add_value;
  done;
done;

end;


define event format_condition;
     putlog "Add conditional formatting";
     set $f_condition["databar"] "4";
     set $f_condition["colorscale"] "3";
     set $f_condition["iconsets"] "6";
     set $f_condition["cellvalue"] "1";
     set $f_condition["expression"] "2";
     set $f_condition["textstring"] "9";
     set $f_condition["uniquevalue"] "4";
     set $format_condition lowcase($format_condition);

     eval $format_type scan($format_condition,1);
     do / if !contains($format_condition,"-");
        eval $b_condition inputn(scan($format_condition,2),"best.");
     do / if cmp($format_type,"iconsets");
        do / if !exist(scan($format_condition,3));
           put " pws.Columns(" $b_condition ").FormatConditions.Add(" $f_condition[$format_type] ");" NL / if $format_condition;
            else;
           eval $icon_type inputn(scan($format_condition,3),"best.");
               put " var Icontype=pws.Columns(" $b_condition ").FormatConditions.Add(" $f_condition[$format_type] ");" NL / if $format_condition;
           put " Icontype.IconSet=wb.IconSets(" $icon_type ");" NL / if $icon_type;
           done;
         else;
           put " pws.Columns(" $b_condition ").FormatConditions.Add(" $f_condition[$format_type] ");" NL / if $format_condition;
        done;

     else;
         eval $b_condition inputn(scan($format_condition,2),"best.");
         eval $b_condition $b_condition-1;
         eval $e_condition inputn(scan($format_condition,3),"best.");
         eval $e_condition $e_condition-1;

         do / while $b_condition <= $e_condition;
            eval $b_condition $b_condition+1;
            put " pws.Columns(" $b_condition ").FormatConditions.Add(" $f_condition[$format_type] ");" NL / if $format_condition;
            putlog $b_condition;
         done;
    done;

end;


define event powerpoint;
   put "<script language=""javascript"">" NL;
   put "function CreatePPT()" NL;
   put "{" NL;
   set $slides reverse($slides);

   do /if index($slides, ",");
      eval $slide_value scan($slides,1,",");
      eval $slidecount 1;

      do /while ^cmp( $slide_value, " ");
         eval $s_value[] reverse(strip($slide_value) );
         eval $slidecount $slidecount +1;
         set $slide_value scan($slides,$slidecount,",");
      done;


   else;
      set $slides reverse($slides);
      set $s_value[] strip($slides);
   done;

   iterate $s_value;
   put " var xl = new ActiveXObject(""Powerpoint.Application"");" NL;
   put " xl.Visible = true;" NL;
   put " var b=xl.Presentations.Add(1);" NL;
   put " var c=b.SlideShowSettings;" NL;
   putq " b.ApplyTemplate(" $Powerpoint_template ");" NL /if $Powerpoint_template;
   put " var ppSlide1 = b.Slides.Add(1,1);" NL;
   eval $first_title scan($ppmaster,1,"#");
   eval $second_title scan($ppmaster,2,"#");
   putq " ppSlide1.Shapes(""Rectangle 2"").TextFrame.TextRange.Text =" $first_title ";" NL /if $ppmaster;
   putq " ppSlide1.Shapes(""Rectangle 3"").TextFrame.TextRange.Text =" $second_title ";" NL /if $second_title;

   do /while _value_;
      putq " var  ppSlide=b.Slides.InsertFromFile(Filename=" _value_ ",1,1);"
            NL;
      next $s_value;
   done;

   putq " b.SaveAs(" $powerpoint_saveas ");" NL /if $powerpoint_saveas;
   put "c.Run();" NL /if $pprun;
   put "}" NL;
   put NL;
   put "</script>" NL;

   do /if cmp( dest_file, "body");
      putq "<input class=""button"" type=button value=""PowerPoint"" onclick=""CreatePPT()"">"  NL /if $slides;
   done;

end;
define event embedded_stylesheet;
   start:
      break / if $script;
      put "<style type=""text/css"">" NL "<!--" NL;

         do / if any($banner_even,$banner_odd,$fbanner_even,$fbanner_odd);
              put ".first {" / if any($banner_even,$fbanner_even);
              put " background-color:"  $banner_even "!important;" NL / if $banner_even;
              put "         color:" $fbanner_even "!important;" NL / if $fbanner_even;
              put "}" NL /  if any($banner_even,$fbanner_even);

              put ".second {" / if any($banner_odd,$fbanner_odd);
              put " background-color:"  $banner_odd "!important;" NL / if $banner_odd;
              put " color:" $fbanner_odd "!important;" NL / if $fbanner_odd;
              put "}" NL / if any ($banner_odd,$fbanner_odd);
         done;

      put "  thead " NL;
      put "{" NL;
      put "  display:table-header-group;" NL;
      put "  cursor:hand; " NL /if $sort;
      put "  text-decoration:underline" NL /if cmp( $options["HEADER_UNDERLINE"], "yes");
      put "}" NL;
      put "#body {behavior:url(#default#userdata);} " NL /if $options["DESIGN_MODE"];

      do /if cmp( STYLE, "MINIMAL") or cmp ( STYLE, "STYLES.MINIMAL");

         do /if cmp( $frozen_headers, "yes");
            put ".header { " NL;
            put " z-index:20;" NL;
            put " POSITION:relative;" NL;
            put " TOP: expression(document.getElementById(""freeze"").scrollTop-3.5)" NL;
            put "}" NL;
         done;


         do /if exists( $frozen_rowheaders);

            do /if ^cmp( $frozen_rowheaders, "no");
               put ".rowheader {" NL;
               put " z-index:30;" NL;
               put " POSITION:relative;" NL;
               put " left:expression(Container=freeze.scrollLeft);" NL;
               put "}" NL;
            done;

         done;

      done;


      do /if $ztable1;

         do /if index($ztable1, ",");
            set $table_zoom scan($ztable1,1,",");
            eval $count 0;

            do /while ^cmp( $table_zoom, " ");
               set $t_zoom[] strip($table_zoom);
               eval $count $count +1;
               set $table_zoom scan($ztable1,$count,",");
               eval $thzid cat("  #hid",$count);
               eval $tbzid cat("#bid",$count);
               put $thzid "," $tbzid "{zoom:" $table_zoom "}" NL;
            done;


         else;
            set $table_zoom strip($ztable1);
            put " #hid1,#bid1 {zoom:" $table_zoom "}" NL;
         done;

      done;


      do /if $options["ZOOM"];
         set $zoom $options["ZOOM" ];
         put NL;
         put " @media screen {td,th {zoom:";
         put $zoom;
         put "}}" NL;
         put NL;
      else /if cmp($frozen_headers_all ,"yes");
         set $zoom "130%";
         put NL;
         put " @media screen {td,th {zoom:";
         put $zoom;
         put "}}" NL;
         put NL;

      else;
         unset $zoom;
      done;


      do /if any( $frozen_headers, $frozen_rowheaders, $options["PRINT_ZOOM"],
                  $options["PAGEHEIGHT"], $options["PAGEWIDTH"]);
         put " @media print { div#freeze, tbody {overflow:visible !important ;" NL;
         put "                 width:auto !important;" NL;
         put "                 height:auto !important;}" NL;
         put "                 thead {display:table-header-group} " NL;
         put "                 td,th {zoom:" $options["PRINT_ZOOM" ];
         put "  }" NL /if $options["PRINT_ZOOM"];
         put "}" NL;
      done;


   do / if any($excel_options,$print_dialog,$hide_cols,$slides,$toc_print,$options['SAVEAS']);
      put ".Button {" NL;
      put "   color:" $options['BUTTON_FGCOLOR'] ";"  NL           / if $options['BUTTON_FGCOLOR'];
      put "   background-color:" $options['BUTTON_BGCOLOR'] ";" NL / if $options['BUTTON_BGCOLOR'];
      put "   font-size:" $options['BUTTON_SIZE'] ";" NL           / if $options['BUTTON_SIZE'];
      put "   font-weight:" $options['BUTTON_WEIGHT'] ";" NL       / if $options['BUTTON_WEIGHT'];
      put " }" NL;
   done;

   finish:

      do /if $web_tabs;
         eval $len length($web_tabs);
         eval $num_tabs count($web_tabs,",") +1;
        /* putlog $num_tabs; */
         put " <!--" NL;

         do / if !$web_tabs_just;
             put ".tabs {position:relative; left:0; top:0;  height: 27px;margin: 0; padding: 0;  }" NL;
         else / if cmp($web_tabs_just,"center");
             put ".tabs {text-align:center;  height: 27px;margin: 0; padding: 0;  }" NL;
         else / if cmp($web_tabs_just,"right");
             put ".tabs {text-align:right;  height: 27px;margin: 0; padding: 0;  }" NL;
         done;

         put ".tabs li {display:inline}" NL;
         put ".tabs a:hover, .tabs a.tab-active {background:beige;}" NL;
         put ".tabs a  { height: 25px; font:11px;font-weight:bold;color:#2B4353;" NL;
         put " color:" $web_tabs_fgcolor "!important;"            / if $web_tabs_fgcolor;
         put " background-color:" $web_tabs_bgcolor "!important;" / if $web_tabs_bgcolor;
         put " position:static; padding:6px 10px 10px 10px;text-decoration:none; }" NL;
         put ".tab-container {  border:0px solid #194367; height:expression(body.clientHeight/2-50);left:expression(body.clientWidth/2 )}" NL;
         put " .tab-panes { margin: 3px; border:0px solid red; height:320px}"  NL;
         put " div.content { padding: 5px; }" NL;
      done;

     do / if cmp($frozen_headers_all,"yes");
          put "thead  th" NL;
          put "{" NL;
          put "position: relative;" NL;
          put "top: expression(this.scrollTop);" NL;
          put "z-index: 10;" NL;
          put "}" NL;

          put ".tableContainer" NL;
          put "{" NL;
          put "overflow-y: scroll;" NL;
          put "height:" $pageheight NL / if $pageheight;
          put "}" NL;
     done;

      trigger alignstyle;
      put NL;

      do / if cmp($frozen_headers,"yes");
         do / if $pageheight;
            put ".Table > tbody {overflow-x:hidden;overflow-y:auto;height:" $pageheight "}" NL;
         else;
            put ".Table > tbody {overflow-x:hidden;overflow-y:auto;height:500px}" NL;
        done;
      done;

      do / if $options["FONTFAMILY"];
          put "* {";
          put "font-family:" $options["FONTFAMILY"] "!important " / if $options["FONTFAMILY"];
          put "}" NL;
      done;

      put ".Header {background-color:" $header_bcolor " !important}" NL / if $header_bcolor;

      put "-->" NL "</style>" NL / if !$script;

end;
define event style_class;
   break / if $script;
   do /if cmp( htmlclass, "DataEmphasis");
      put ".noFilter" NL;
      put "{" NL;

      trigger stylesheetclass;
      put NL;
      put "}" NL;
   done;


   do /if cmp( htmlclass, "contentprocname") or cmp ( htmlclass,"contentproclabel") or cmp ( htmlclass, "contentfolder") or
          cmp (htmlclass, "bycontentfolder");
       put ".expandable";

   else;
      put "." HTMLCLASS NL;
   done;

       put "{" NL;

   trigger stylesheetclass;

   do /if cmp( htmlclass, "header");

      do /if cmp( $frozen_headers, "yes");
         put " z-index:20;" NL;
         put " POSITION:relative;" NL;
         put " TOP: expression(document.getElementById(""freeze"").scrollTop-1);" NL;
      done;

      do /if any( $options["HEADER_BGCOLOR"], $options["HEADER_FGCOLOR"], $options["HEADER_SIZE"], $options["HEADER_FONT"]);

         do /if cmp( htmlclass, "header");
            put "  background-color:" $options["HEADER_BGCOLOR" ] ";" NL /if $options["HEADER_BGCOLOR"];
            put "  color:" $options["HEADER_FGCOLOR" ] ";" NL            / if $options["HEADER_FGCOLOR"];
            put "  font-size:" $options["HEADER_SIZE" ] ";" NL           / if $options["HEADER_SIZE"];
            put "  font_family:" $options["HEADER_FONT" ] ";" NL         / if $options["HEADER_FONT"];
         done;

      done;

   done;


   do /if cmp( htmlclass, "rowheader");

      do /if any( $options["ROWHEADER_BGCOLOR"], $options["ROWHEADER_FGCOLOR"],$options["ROWHEADER_SIZE"], $options["ROWHEADER_FONT"]);
         put "  background-color:" $options["ROWHEADER_BGCOLOR" ] ";" NL  /if $options["ROWHEADER_BGCOLOR"];
         put "  color:" $options["ROWHEADER_FGCOLOR" ] ";" NL             /if $options["ROWHEADER_FGCOLOR"];
         put "  font-size:" $options["ROWHEADER_SIZE" ] ";" NL            /if $options["ROWHEADER_SIZE"];
         put "  font_family:" $options["ROWHEADER_FONT" ] ";" NL          /if $options["ROWHEADER_FONT"];
      done;


      do /if exists( $frozen_rowheaders);

         do /if ^cmp( $frozen_rowheaders, "no");
            put " POSITION:relative;" NL;
            put " left:expression(Container=freeze.scrollLeft);" NL;
         done;

      done;
   done;


   do /if any( $options["DATA_BGCOLOR"],$options["DATA_FGCOLOR"],$options["DATA_SIZE"],$options["DATA_FONT"],$options["DATA_WEIGHT"]);

      do /if cmp( htmlclass, "data");
         put "  background-color:" $options["DATA_BGCOLOR" ] ";" NL /if $options["DATA_BGCOLOR"];
         put "  color:" $options["DATA_FGCOLOR" ] ";" NL            /if $options["DATA_FGCOLOR"];
         put "  font-size:" $options["DATA_SIZE" ] ";" NL           /if $options["DATA_SIZE"];
         put "  font_family:" $options["DATA_FONT" ] ";" NL         /if $options["DATA_FONT"];
         put "  font-weight:" $options["DATA_WEIGHT" ] ";" NL       /if $options["DATA_WEIGHT"];
     done;

   done;

done;


do /if $gridline_color and cmp( htmlclass, "table");
   put "  background-color:" $gridline_color;
done;


do /if $options["BACKGROUND_COLOR"];

   do /if contains( htmlclass, "systemtitle") or contains ( htmlclass, "systemfooter")
            or contains ( htmlclass, "systitleandfootercontainer");
      put " background-color:" $options["BACKGROUND_COLOR" ] ";" NL;
   done;

done;


do /if any( $options["TITLE_STYLE"], $options["TITLE_SIZE"],$options["TITLE_FGCOLOR"],$options["TITLE_BGCOLOR"]);

   do /if cmp( htmlclass, "systemtitle") or cmp( htmlclass, "systemtitle2") or cmp( htmlclass, "systemtitle3")
          or cmp( htmlclass, "systemtitle4") or cmp( htmlclass, "systemtitle5") or cmp( htmlclass, "systemtitle6")
          or cmp( htmlclass, "systemtitle7")  or cmp( htmlclass, "systemtitle8") or cmp( htmlclass, "systemtitle9")
          or cmp( htmlclass, "systemtitle10") or cmp( htmlclass, "systemfooter") or cmp( htmlclass, "systemfooter2")
          or cmp( htmlclass, "systemfooter3") or cmp( htmlclass, "systemfooter4") or cmp( htmlclass, "systemfooter5")
          or cmp( htmlclass, "systemfooter6") or cmp( htmlclass, "systemfooter7") or cmp( htmlclass, "systemfooter8")
          or cmp( htmlclass, "systemfooter9") or cmp( htmlclass, "systemfooter10")
          or cmp ( htmlclass, "systitleandfootercontainer");

      put " font-style:" $options["TITLE_STYLE" ] ";" NL /if $options["TITLE_STYLE"];
      put " font-size:" $options["TITLE_SIZE" ] ";" NL /if $options["TITLE_SIZE"];
      put " color:"  $options["TITLE_FGCOLOR"] ";" NL / if $options["TITLE_FGCOLOR"];
      put " background-color:" $options["TITLE_BGCOLOR"] ";" NL / if $options["TITLE_BGCOLOR"];
   done;

done;


do /if any( $options["TOP_MARGIN"], $options["BOTTOM_MARGIN"], $options["LEFT_MARGIN"], $options["RIGHT_MARGIN"]);

   do /if cmp( htmlclass, "body");
      put "  margin-top:" $options["TOP_MARGIN" ] ";" NL /if $options["TOP_MARGIN"];
      put "  margin-bottom:" $options["BOTTOM_MARGIN" ] ";" NL /if $options["BOTTOM_MARGIN"];
      put "  margin-left:" $options["LEFT_MARGIN" ] ";" NL /if $options["LEFT_MARGIN"];
      put "  margin-right:" $options["RIGHT_MARGIN" ] ";" NL /if $options["RIGHT_MARGIN"];
   done;

done;

put "}" NL;

trigger link_classes /if cmp( htmlclass, "document");

trigger table_border_vars /if cmp( htmlclass, "table");

trigger batch_border_vars /if cmp( htmlclass, "batch");

trigger graph_border_vars /if cmp( htmlclass, "graph");

trigger container_border_vars /if contains( htmlclass,"systitleandfootercontainer");

trigger stacked_column_styles /if cmp( htmlclass, "table");
end;
define event link;
   put "<link";
   set $curstyle translate(style," ",".");
   set $curstyle lowcase($curstyle);
   eval $curtitle lowcase(scan($title,1,".") );

   do /if cmp( $options["STYLE_SWITCH"], "yes");

      do /if contains( $curstyle, $curtitle);
         put " rel=""stylesheet""";

      else;
         put " rel=""alternate stylesheet""";
      done;


   else;
      put " rel=""stylesheet""";
   done;

   putq " type=""text/css"" href=" $current_url;
   putq " title=" $title;
   put $empty_tag_suffix;
   put "/>" NL;
end;
define event urlLoop;
   eval $index 1;
   set $current_url scan($urlList,$index," ");

   do /while ^cmp( $current_url, " ");
      set $current_url trim($current_url);
      eval $title reverse(scan(reverse($current_url) , 1 , "\" ) );
      set $tlist[] $title;

      trigger link;
      eval $index $index +1;
      set $current_url scan($urlList,$index," ");
   done;


   do /if cmp( $options["STYLE_SWITCH"], "yes");
      put "<script>" NL;
      put "function changeStyle(title) {" NL;
      put "var lnks = document.all.tags('link');" NL;
      put "for (var i = lnks.length - 1; i >= 0; i--) {" NL;
      put  %nrstr("if %(lnks[i].getAttribute%('rel'%).indexOf%('style'%)> -1 && lnks[i].getAttribute%('title'%)%) {") NL;
      put "lnks[i].disabled = true;" NL;
      put "if (lnks[i].getAttribute('title') == title) lnks[i].disabled = false;" NL;
      put "}}}" NL;
      put "</script>" NL;
   done;

end;

define event output;
      break / if $script;
      put "<div style=""text-align:";
      set $div_style "center" /if cmp( getoption("center"), "center");
      set $div_style "left" /if ^cmp( getoption("center"), "center");
      put $div_style;

      do / if $pageheight;
      eval  $pageh_ex upcase(reverse(substr(reverse($pageheight),1,1)));
      put " ;height:100%" / if cmp($pageh_ex,"%");
      done;

      put """";
      put ">" NL;

   finish:
      break / if $script;
      put "</div>" NL;
      put "<br";
      put ">" NL;

end;

define event title_container;
     break / if $script;
     break  / if cmp($switch_titles,"yes");
     start:
            put "<table";
            putq " class=" HTMLCLASS;

            trigger style_inline;
            put %nrstr(" width=""100%%""");
            putq " cellspacing=" CELLSPACING;
            putq " cellpadding=" CELLPADDING;
            putq " rules=" LOWCASE(RULES);
            putq " frame=" LOWCASE(FRAME);

            trigger put_container_border_vars;
            put " summary=""Page Layout"">" NL;

         finish:
            break / if $script;
            break / cmp($switch_titles,"yes");
            put "</table><br";
            put $empty_tag_suffix;
            put ">" NL;

 end;
 define event title_container_row;
    break / if $script;
    break / cmp($switch_titles,"yes");
    put "<tr>" NL;

    finish:
    break / if $script;
    break / cmp($switch_titles,"yes");
    put "</tr>" NL;
 end;

 define event system_title;
       start:
             trigger spanhead1 / if !$script;

       finish:
             trigger spanhead1 / if !$script;
 end;

 define event system_footer;
      start:
          trigger spanhead1 / if !$script;

      finish:
          trigger spanhead1 / if !$script;
 end;

 define event panel_attributes;
   do / if ^$options['PANEL_JUST'];
      put " align=center";
   else;
      put " align= " $options['PANEL_JUST'] ;
   done;

   do / if ^$options['PANEL_BORDER'];
      put " border=""0""" ;
   else;
      putq " border=" $options['PANEL_BORDER'];
   done;
end;


define event proc;
  break / if $script;
  eval $table_count 0;
   unset $cap;
    do / if !$pageheight;
      set $ptest "S" / if $options["PANELROWS"];
      put "<div class=""branch"">" NL / if !$web_tabs;
      put "<tr>" / if cmp($ptest,"S");
    done;

     /* set $panelcols $options["PANELCOLS" ];
      set $panelcols $options["PANELROWS" ]; */

      eval $panel[] event_name;
      /*eval $panel[event_name] $panel[event_name ] +1;*/
      set $pantmp $panel;

      do /if any($options["PANELCOLS"],$options["PANELROWS"]);

         set $panelcols $options["PANELCOLS" ];
         set $panelcols $options["PANELROWS" ];

         set $endcol sum($pantmp,$panelcols);
         eval $endcol inputn($endcol,"best");
         eval $endcol $endcol -1;

         set $endrow sum($pantmp,$panelrows);
         eval $endrow inputn($endrow,"best");
         eval $endrow $endrow -1;


         set $startx[] $pantmp;
         put "<p style=""page-break-after: always;""><br></p><hr size=""3"">"  NL /if $panel > 1;

         do /if exist( $web_tabs);


             eval $cpan catx("_","panel",$pantmp);
             put "<div class=""branch"" ";
             putq "id=" $cpan;
             put ">" NL;

         done;

         put "<table" ;
         trigger panel_attributes;
         put ">" NL;;
         put "<tr>" NL;
      done;


      do /if exist( $startx[$pantmp]);
         put "</td>" NL /if ^$options["PANELCOLS"];
         put "<td>" NL / if ^$options["PANELCOLS"];;
         *put "<tr>" NL / if $panelcols;
         put "<td>" NL / if $options["PANELCOLS"];;;
     done;

      /* only for dynamic output */

      /*set $last_tab $tab_name;
      set $tab_name $options['TAB_NAME'];*/

      /*do / if any($panelcols);
            put "<div class=""branch"" " ;
            eval $cpan catx("_","panel",$panel[event_name]);
            putq "id=" $cpan ;
            put ">" NL;
      done; */


     /* Only for dynamic output */
     /*  open tab;
              put "<li style=""border-right: 1px solid #194367;";
              put "display:none""" / if cmp($last_tab,$tab_name);
              put ">" NL;
              put "<a href=""#"" onClick=""return showPane""";
              put "('" $cpan "',this)"" id=""tab1"">" $tab_name "</a>" NL;
              put "</li>" NL;

      close;
      */


      do /if exist( $web_tabs);

        eval $cpcnt $panel;
         do / if  $cpcnt <= $num_tabs;

         do / if !cmp($panel,$endcol);

          do / if !cmp($last_tab,$tab_name);
            put "<div class=""branch"" " ;
            eval $cpan catx("_","panel",$panel);
            putq "id=" $cpan ;
            put ">" NL;
          done;
        done;
      done;
   done;


   finish:
      break / if $script;
      put "</div>" NL;

      set $x $endcol;
      set $y $pantmp;
      set $z $endrow;
      /*putlog $x $y;*/

      do /if cmp( $x, $y);
         put "</tr style=""xx"">" NL;
         put "</table>" NL;
         put "</div>" NL;

      do /if cmp( $z, $y);
         put "</tr style=""xx"">" NL;
         put "</table>" NL;
         put "</div>" NL;



     do / exist($web_tabs);
        put "</div>" NL /  if  $cpcnt = $num_tabs;
        put "</div>" NL /  if  $cpcnt = $num_tabs;
        put "</div>" NL /  if  $cpcnt = $num_tabs;
    done;

   done;


     done;

    unset $options["PANELCOLS" ];
    unset $options["PANELROWS" ];
    unset $options["PANEL_JUST" ];
    unset $options["PANEL_BORDER" ];


end;

define event web_tabs_output;

do /if index($web_tabs, ",");
    set $tab_value scan($web_tabs,1,",");
    eval $tabcount 1;

       do /while ^cmp( $tab_value, " ");
           set $tab_col[] strip($tab_value);
           eval $tabcount $tabcount +1;
           set $tab_value scan($web_tabs,$tabcount,",");
       done;


 else;
      set $tab_col[] strip($web_tabs);
done;

     eval $pane_count 1;
     iterate $tab_col;
       put "<div class=""tab-container"" id=""container1"">" NL;
       put "<ul class=""tabs"">" NL;

       do /while _value_;
          put "<li style=""border-right: 1px solid #194367;"" >" NL;
          put "<span style=""display:none"">" / if cmp(_value_,"hide");
          put "<a href=""#"" onClick=""return showPane(";
          eval $tab_pane cat("tab",$pane_count);
            eval $pane_tab cat("panel_",$pane_count);
            put "'" $pane_tab "'" ",this)"" id=" """" $tab_pane """" ">";
            put _value_ "</a>" NL;
            put "</span>" / if cmp(_value_,"hide");
            put " </li>" NL;
            eval $pane_count $pane_count +1;
            next $tab_col;
        done;

         put "</ul>" NL;
         put "  <div class=""tab-panes"">" NL;
      done;
end;

define event pagesetup;
   do /if cmp( $options["ORIENTATION"], "landscape");
       set $print_orientation "false";
     else;
       set $print_orientation "true";
     else;
     unset $print_orientation;
   done;

do /if $options["PRINT_HEADER"];
    set $print_header $options["PRINT_HEADER" ];
  else;
  unset $print_header;
done;

do /if $options["PRINT_FOOTER"];
    set $print_footer $options["PRINT_FOOTER" ];
  else;
   unset $print_footer;
done;

  put "<object id=""factory"" style=""display:none"" viewastext" NL;
  put "  classid=""clsid:1663ed61-23eb-11d2-b92f-008048fdd814"" " NL;
  put "  codebase=""http://www.meadroid.com/scriptx/smsx.cab#Version=6,2,433,70"">" NL;
  put "</object>" NL;
  put NL;
  put " <script defer>" NL;
  put "  function viewinit() {" NL;
  put "    if (!factory.object) {" NL;
  put "    return " NL;
  put " } else {" NL;
  putq "  factory.printing.header = " $print_header NL;
  putq "  factory.printing.footer = " $print_footer NL;
  put "  factory.printing.portrait =" $print_orientation NL;
  put " }" NL;
  put "}" NL;
  put "</script>" NL;
  put NL;
end;

define event Auto_Format_select;
         put "<div style=""float:left"">" NL;
         put "<form class=""nodisplay"" name=""forms"">" NL;
         put "<Fieldset style=""width:66;font-size:12;color:black"">";
         put "<legend>Excel Styles</legend>" NL;
         put "<select  onchange=Exstyle(this.options[this.selectedIndex].value) size=1 name=forms>" NL;
         put "<option value=""1"">classic1" NL;
         put "<option value=""2"">classic2" NL;
         put "<option value=""3"">classic3" NL;
         put "<option value=""4"">accounting1" NL;
         put "<option value=""5"">accounting2" NL;
         put "<option value=""6"">accounting3" NL;
         put "<option value=""17"">accounting4" NL;
         put "<option value=""31"">classicpivottable" NL;
         put "<option value=""7"">colorful1" NL;
         put "<option value=""8"">colorful2" NL;
         put "<option value=""9"">colorful3" NL;
         put "<option value=""10"">list1" NL;
         put "<option value=""11"">list2" NL;
         put "<option value=""12"">list3" NL;
         put "<option value=""13"">3deffects1" NL;
         put "<option value=""14"">3deffects2" NL;
         put "<option value=""21"">report1" NL;
         put "<option value=""31"">table9" NL;
         put "<option value=""41"">table10" NL;
         put "<option value=""42"">ptnone" NL;
         put "<option value=""4142"">none" NL;
         put "<option value=""4154"">simple" NL;
         put "</select>" NL;
         put "</Fieldset>" NL;
         put "</form>" NL;
         put "</div>" NL;
  end;
  define event zoom_toggle;
         put "<script>" NL;
         put "  function zoomtog(val) { " NL;
         put "    body.style.zoom=val;  }" NL;
         put "</script>" NL;
         put "<div style=""float:left"">" NL;
         put "<form class=""nodisplay"" name=""form"">" NL;
         put "<Fieldset style=""width:66;font-size:12;color:black"">";
         put "<legend>Zoom</legend>" NL;
         put "<select  onchange=zoomtog(this.options[this.selectedIndex].value) size=1 name=form>" NL;
         put %nrstr("<option value=""100%%"">100%%") NL;
         put %nrstr("<option value=""200%%"">200%% ") NL;
         put %nrstr("<option value=""300%%"">300%%") NL;
         put %nrstr("<option value=""400%%"">400%% ") NL;
         put %nrstr("<option value=""75%%"">75%% ") NL;
         put %nrstr("<option value=""50%%"">50%% ") NL;
         put "</select>" NL;
         put "</Fieldset>" NL;
         put "</form>" NL;
         put "</div>" NL;
  end;

  define event Pagebreak_Toggle;
         put "<div style=""float:left"">" NL;
         put "<FORM class=""nodisplay"" name=myform><INPUT onclick=toggleheader() type=checkbox name=mybox checked>" NL;
         put "<Fieldset style=""width:66;font-size:12;color:black"">" NL;
         put "<legend>Page Break Toggle</legend>" NL;
         put "</Fieldset>" NL;
         put "</FORM>" NL;
         put "</div> " NL;
         put NL;
         put "<SCRIPT>" NL;
         put "function toggleheader(){" NL;
         put  "var toggle=(document.forms.myform.mybox.checked)? ""always"" : """" " NL;
         put "for (i=0; i<document.getElementsByTagName(""P"").length; i++)"  NL;
         put "document.getElementsByTagName(""P"")[i].style.pageBreakAfter=toggle" NL;
         put NL;
         put "var newstyle=(document.forms.myform.mybox.checked)? ""block"" : ""none"" " NL;
         put "for (i=0; i<document.getElementsByTagName(""HR"").length; i++)"  NL;
         put "document.getElementsByTagName(""HR"")[i].style.display=newstyle"  NL;
         put "}" NL;
         put "</SCRIPT>" NL;
  end;

  define event Print_Dialog;
         put "<script>" NL;
         put "function printpr(olecmdid)" NL;
         put "{" NL;
         put "//var olecmdid = 10;" NL;
         put "// olecmdid values: " NL;
         put "// 6 - print " NL;
         put "// 7 - print preview" NL;
         put "// 8 - page setup " NL;
         put "// 1 - open window" NL;
         put "// 4 - Save As" NL;
         put "// 10 - properties" NL;
         put %nrstr("var PROMPT = 1; // 1 PROMPT & 2 DONT PROMPT USER ") NL;
         put  "var WebBrowser = '<OBJECT ID=""WebBrowser1"" WIDTH=0 HEIGHT=0 CLASSID=""CLSID:8856F961-340A-11D0-A96B-00C04FD705A2""></OBJECT>'; " NL;
         put "document.body.insertAdjacentHTML('beforeEnd', WebBrowser); " NL;
         put "WebBrowser1.ExecWB(olecmdid,PROMPT); " NL;
         put "WebBrowser1.outerHTML = """"; " NL;
         put "}" NL;
         put "</script>" NL;
         put "<div style=""float:left"">" NL;
         put "<form class=""nodisplay"" name=""form1"">" NL;
         put "<Fieldset style=""width:66;font-size:12;color:black"">";
         put "<legend>Toolbar Menu</legend>" NL;
         put "<select name=""olecmdid"">" NL;
         put "<option value=""6"">Print" NL;
         put "<option value=""7"">Print Preview " NL;
         put "<option value=""8"">Page Setup" NL;
         put "<option value=""1"">Open File" NL;
         put "<option value=""4"">Save As" NL;
         put "<option value=""10"">Properties" NL;
         put "</select>" NL;
         put "</Fieldset>" NL;
         put "<input class=""button"" type=""Button"" value=""Go"" onclick=""printpr(document.form1.olecmdid.value);""> " NL;
         put "</form>" NL;
         put "</div>" NL;
  end;

define event doc_body;
eval $xlsheet 0;

   do /if cmp( dest_file, "body") and cmp ( $excel_options , "true") and  ^cmp($format_email,"yes");;

     do / if $button_text;
          set $export_label $button_text;
       else / if $file_format and ^$button_text;
          eval $export_label catx(" ","Export",$file_format);
       else;
          set $export_label "Export";
    done;

    do /if ^cmp( $options["AUTO_FORMAT_SELECT"], "yes");
       do / if !$script;
         putq "<span style=""float:left""><input class=""button"" type=button value=" $export_label  %nrstr("onclick=""CopyExcel%(%)"">&nbsp;</span>") NL /if ^cmp( $file_format, "doc");
       done;
   done;

         put %nrstr("<span style=""float:left""><input class=""button"" type=button value=""Export to Word"" onclick=""CopyWord%(%)"">&nbsp;</span>") NL /if cmp( $file_format, "doc");
    done;
        put  "<span style=""float:left""><input class=""button"" type=""button"" value=""Refresh"" onclick=""refresh()"" /></span>" NL /if $hide_cols;

      do /if cmp( $options["STYLE_SWITCH"], "yes");
         put "<div style=""float:left"">" NL;
         put "<form id=""switch"">" NL;
         put "<Fieldset style=""width:66;font-size:12;color:black"">" NL;
         put "<legend>Style Switch</legend>" NL;
         put "<select name=""switchcontrol"" size=""1"" onChange=""changeStyle(this.options[this.selectedIndex].value)"">" NL;
         iterate $tlist;

         do /while _value_;
            putq "<option value=" _value_ ">";
            put _value_ "</option>" NL;
            next $tlist;
         done;

         put "</select>" NL;
         put "</Fieldset>" NL;
         put "</form>" NL;
         put "</div>" NL;
      done;

    do / if !$script;
      put "<body onload=""startup()""";
      put " onunload=""shutdown()""";

      do /if cmp( $fit2page, "yes");
         put " onbeforeprint=""before()""";
         put " onafterprint=""after()"" " NL;
      done;

      put " bgproperties=""fixed""" / WATERMARK;
      putq " class=" HTMLCLASS;
      putq " background=" BACKGROUNDIMAGE;

      do /if cmp( $options["DESIGN_MODE"], "yes");
         put " CONTENTEDITABLE";
      done;

      put " id=""body""";
      putq " background=" $background_image /if $background_image;

      do /if cmp( $options["REORDER_COLS"], "yes");
         put  "  onmouseup  = ""  z=0;        lay1.style.display='none'; setTimeout('BlurHead() ; ',100); "" ";
         put  "  onmousedown= ""  if (z==1) { lay1.style.display=''    ; lay1.style.left=x; lay1.style.top=y;  } "" ";
      done;

      put ">" NL;

      trigger pre_post;
      put NL;

      trigger ie_check;

   done; /* script file */

      /* Created tabbed output */
      trigger web_tabs_output / if $web_tabs;
      trigger pagesetup / if any( $options["PRINT_HEADER"], $options["PRINT_FOOTER"], $options
               ["ORIENTATION"]);

      put "<style media=""print""> .nodisplay {display:none} </style>" NL /if  any( $options["ZOOM_TOGGLE"], $options["PAGEBREAK_TOGGLE"], $options["PRINT_DIALOG"]);
      trigger Auto_Format_select / if cmp( $options["AUTO_FORMAT_SELECT"], "yes");
      trigger Zoom_Toggle / if cmp( $options["ZOOM_TOGGLE"], "yes");
      trigger PageBreak_Toggle / if cmp( $options["PAGEBREAK_TOGGLE"],"yes");
      trigger Print_Dialog / if cmp( $options["PRINT_DIALOG"], "yes");


    open xlstream;

     do / if !$script;

       put "<script language=""javascript"">" NL;
       do /if cmp( $options["AUTO_FORMAT_SELECT"], "yes");
            put "function Exstyle(val) { " NL;
        else;
            put "function CopyExcel()" NL;
            put "{" NL;

      /*****************************************************/
      /* Added script to handle IE 10 changes to copy data */
      /*****************************************************/

      put  " function selectElementContents(el) {" NL;
      put  " var body = document.body, range, sel;" NL;
      put  "if (document.createRange %nrstr(&&) window.getSelection) {" NL;
      put  "    range = document.createRange();" NL;
      put  "      sel = window.getSelection();" NL;
      put  "      sel.removeAllRanges();" NL;
      put  "      try { " NL;
      put  "          range.selectNodeContents(el);" NL;
      put  "          sel.addRange(range);" NL;
      put  "      } catch (e) {" NL;
      put  "          range.selectNode(el);" NL;
      put  "          sel.addRange(range);" NL;
      put  "      }" NL;
      put  "  } else if (body.createTextRange) {" NL;
      put  "      range = body.createTextRange();" NL;
      put  "      range.moveToElementText(el);" NL;
      put  "      range.select();" NL;
      put  "  }"  NL;
      put  "}" NL;

     done;

            put "var _infox = navigator.userAgent;" NL;
            put "var _iex = (_info.indexOf(""MSIE"") > 0); " NL;
            put "if (_iex !=true) alert(""Export features supported on I.E only"");" NL;

           /* Commented out because of replacement select module */
           /* put " var tr = document.body.createTextRange();" NL;*/

            do /if exist( $excel_table_move);
               set $move $excel_table_move;
            done;
                put " document.execCommand(""copy"");" NL;
    done; /*end script */

                  put " var xl = new ActiveXObject(""Excel.Application"");" NL;

                  do /if cmp( $open_excel, "no") or cmp($excel_open,"no");
                     put " xl.Visible = false;" NL;

                  else;
                     put " xl.Visible = true;" NL;
                  done;


                  do /if any( $query_target, $update_target);
                     putq " var wb = xl.Workbooks.Open(" $query_target ");"  NL  / if $query_target;
                     putq " var wb = xl.Workbooks.Open(" $update_target ");" NL  / if $update_target;
                  done;


                  put " var wb = xl.Workbooks.Add();" NL /if ^any( $query_target, $update_target);
                  putq " wb.Sheets(" $update_sheet ").Activate();" NL /if $update_sheet;

                  put " var sheet = wb.ActiveSheet;" NL;

                  do /if exists( $update_target);
                     put " sheet.Cells(" $update_range ").Activate();" NL /if $update_range;

                    /* Insert test pivot recursive */

                  put "ActiveWorkbook.ShowPivotTableFieldList=0" / if cmp($options["PIVOT_FIELDLIST"],"no");

                 do /if index($sheet_name,",");
                    eval $nums count($sheet_name,",");
                    /* putlog "number of sheets " $nums; */
                    eval $countx 0;

                  do /while $countx <= $nums;
                     eval $countx $countx +1;


                     /* Added 8/1/2008 */
                    /* eval $table_list reverse($table_list);
                     eval $tid cat(" id",$table_list);*/

                   /*  putq " sheet.Name=" $sheet_list ";" NL /if $sheet_list;*/
                     trigger pivot_tables /if any( $pivotrow, $pivotcol, $pivotpage,
                     $pivotdata);

					/* trigger excelchart / if cmp($pivotcharts,"yes");*/
					 
                  done;

               done;
               done;

              /* end of testing */


              done;
           close;


   finish:

      trigger pre_post;

      do /if exist( $include);
         put "<div style=""text-align:center""><iframe ";
         putq " src=" $include;
         put %nrstr(" width=100%% height=700></iframe></div>") NL;
      done;


      do / cmp( $options["REORDER_COLS"], "yes");
         put "<div ID=""lay1"" " NL;
         put "     style=""position:absolute; left:0; top:0; display:none; font-weight:bold; text-align:center;" NL;
         put "             background-color: blue; font-family:Verdana; font-size: 14; size:14; color:white;" NL;
         put "             height:20; width:90;"" " NL;
         put ">" NL;
         put " ColName" NL;
         put "</div>" NL;
      done;

         /* Added 8/23/ 2012 */

         do / if exists($web_tabs);
             put "</div>" NL;
             put "</div>" NL;
     done;


      put "</body>" NL / if !$script;


      do / if cmp($excel_options,"true");
      open xlstream;

          put "xl.DisplayAlerts =0;" NL;

          putq " xl.Run(" $macro ");" NL /if $macro;

          do /if cmp( $excel_save_prompt, "yes");
              put  "file=prompt(""Where would you like to save the file"" ";
             do / if $options['DEFAULT_FILE'];
                 putq  "," $options['DEFAULT_FILE'] / if $options['DEFAULT_FILE'];
             else;
                 put "," "' '";
             done;
                 put   ");" NL ;
                 putq " sheet.SaveAs(file";
                 putq "," $export_format[$file_format ] /if $file_format;
                 put ");" NL;
            done;


               do /if cmp( $excel_save_dialog, "yes");
                  putq " xl.GetSaveAsFilename(";
                  putq $options["DEFAULT_FILE"] /if $options["DEFAULT_FILE"];

                  do / if contains($options["DEFAULT_FILE"],".xls");
                       put ",""Excel files (*.xls),*.xls""";
                  else / if contains($options["DEFAULT_FILE"],".txt");
                       put ",""Text files (*.txt),*.txt""";
                  done;

                  put ");" NL;
               done;


               do /if $options["EXCEL_SAVE_FILE"];
                  putq " sheet.SaveAs(" $options["EXCEL_SAVE_FILE" ];
                  putq "," $export_format[$file_format ] /if $file_format;
                  put ");" NL;
               done;

                do /if $options["EXCEL_SHEET_PROMPT"];
                  put  "file=prompt("" Name the sheet for this file"")" NL;;
                  putq " sheet.Name=file" ";"  NL;
               done;

               do / if ^$update_target;
                 putl;
                 put "// delete unused sheets" NL;

            do /if $delete_sheets;

              do /if index($delete_sheets,",");
                set $del_sheet_value scan($delete_sheets,1,",");
                eval $del_sheet_count 1;

              do /while ^cmp($del_sheet_value, " ");
                 set $delete_sh[] strip($del_sheet_value);
                 eval $del_sheet_count $del_sheet_count+1;
                 set $del_sheet_value scan($delete_sheets,$del_sheet_count,",");

              done;

              else;
                 set $delete_sh[] strip($delete_sheets);
              done;

              iterate $delete_sh;
                 do /while _value_;
                    putq " wb.Sheets(" _value_ ").Delete;" NL;
                 next $delete_sh;
                done;
             done;

           done;

               /* put "CollectGarbage();" NL;*/
               put "xl.DisplayAlerts = 1" NL ;

               put 'xl.CutCopyMode = 0;' NL;
               put 'xl.EnableEvents = 0;' NL;
               put "xl = null;" NL / if !cmp( $options["QUIT"], "yes");

			   do / if !$script;
                  put "setTimeout(""CollectGarbage()"",1);" NL / if !exist($excel_save_prompt);
			   done;

               do /if cmp( $options["QUIT"], "yes");
                  put "xl.Quit();" NL;
               done;

               put "}" NL / if !$script;
               put NL;

               do /if cmp( $file_format, "doc");
                  put "function CopyWord()" NL;
                  put "{" NL;
                  put "var tr = document.body.createTextRange();" NL;
                  put "tr.select();" NL;
                  put "document.execCommand(""copy"");" NL;
                  put "var word = new ActiveXObject(""word.application"");" NL;
                  put " word.Visible = true" NL;
                  put " word.Documents.Add();" NL;
                  put " word.Selection.Paste();" NL;
                  put "}" NL;
               done;

               put "</script>" NL /  if !$script;
          close;
       done;

end;

define event user_caption;
    set $cap $options["CAPTION_TEXT" ];
    set $cap_just $options["CAPTION_JUST" ];
    set $cap_background $options["CAPTION_BACKGROUND" ];
    set $cap_color $options["CAPTION_COLOR" ];
    set $cap_size $options["CAPTION_SIZE" ];
    set $cap_style $options["CAPTION_STYLE" ];
    set $cap_image $options["CAPTION_IMAGE" ];

     do /if $cap;

        do /if index($cap, ",");
            set $cap_value scan($cap,1,",");
            eval $capcount 1;

            do /while ^cmp( $cap_value, " ");
                set $cap_row[] strip($cap_value);
                eval $capcount $capcount +1;
                set $cap_value scan($cap,$capcount,",");
            done;


            else;
               set $cap_row[] strip($cap);
            done;

            eval $capscount 1;
            iterate $cap_row;

            do /while _value_;
               set $cjust scan($cap_just,$capscount) /if $cap_just;
               set $ccolor scan($cap_color,$capscount) /if $cap_color;
               set $cbackcolor scan($cap_background,$capscount) /if $cap_background;
               set $cfontsize scan($cap_size,$capscount)    /if $cap_size;
               set $cfontstyle scan($cap_style,$capscount)  /if $cap_style;
               set $cbackimage scan($cap_image,$capscount)  /if $cap_image;
               eval $capscount $capscount +1;
               put "<caption class=""header"" ";
               put " style=""" /if any( $cap_just, $cap_background, $cap_color,$cap_style,$cap_image, $cap_size);
               put "text-align:" $cjust ";"            /if $cap_just;
               put "background-color:" $cbackcolor ";" /if $cap_background;
               put "color:" $ccolor ";"                /if $cap_color;
               put "font-size:" $cfontsize ";"         /if $cap_size;
               put "font-style:" $cfontstyle ";"       /if $cap_style;
               put "background-image:URL("             /if $cap_image;
               putq $cbackimage ")"                    /if $cap_image;
               put """" /if any( $cap_just, $cap_background, $cap_color, $cap_style, $cap_image, $cap_size);
               put ">";
               put _value_;
               put "</caption>" NL  /if exists( $cap);
               next $cap_row;
            done;
         done;
   end;


  define event verbatim_container;
     start:
       do / if cmp(htmlclass,'batch') and exist($update_target);
          do / if ^cmp($options['PIVOT_SERIES'],"yes");

            do /if !index($sheet_name,",");
              do / if any($pivotrow,$pivotcol,$pivotpage,$pivotdata);
                  open xlstream;
                   trigger pivot_tables_single;
                  close;
                   done;
          done;
          else;
          do / if $options['PIVOT_SERIES'];
              do /if index($pivotrow,"|");
                  eval $nums count($pivotrow,"|");
               else / if index($pivotcol,"|");
                  eval $nums count($pivotcol,"|");
               else / if index($pivotdata,"|");
                  eval $nums count($pivotdata,"|");
               else / if index($pivotpage,"|");
                  eval $nums count($pivotpage,"|");
               done;

               /*putlog "number of sheets " $nums; */
               eval $countx 0;

               do /while $countx <= $nums;
                  eval $countx $countx +1;
                 /* putlog "Countx=" $countx;*/
                  open xlstream;
                  trigger pivot_tables;
                  close;
               done;

            done;
         done;
      done;

            break / if $script;
            put "<div";

            trigger alt_align;
            put ">" NL;

            trigger pre_post;
            put "<table";
            putq " class=" HTMLCLASS;

            trigger style_inline;
            putq " cellspacing=" CELLSPACING;
            putq " cellpadding=" CELLPADDING;
            putq " rules=" LOWCASE(RULES);
            putq " frame=" LOWCASE(FRAME);
            put " summary=""Page Layout""";
            put ">" NL;

         finish:
            break / if $script;
            put "</table>" NL;

            trigger pre_post;
            put "</div>" NL;
    end;

define event table;
   start:
      break / if $script;
      eval $count[] event_name;
      eval $rowcount["row" ] 0;

      /* Modify for 9.3 */
      /* eval $count[event_name] $count[event_name] +1; */
      eval $test_count $count;

      eval $id cat("id",$count);
      set $keepid[] $id;
      put "<div";
      put " class=""tableContainer"" " / if cmp($frozen_headers_all,"yes");

      do /if any($pageheight,$pagewidth,$frozen_headers,$frozen_rowheaders);
         putq " style=""overflow:auto; ";

         do /if $pagewidth;
            put " width:" $pagewidth;
         else / if $frozen_rowheaders and ^$pagewidth;
            put " width:expression(document.body.clientWidth-75);";

         else;
            put " width:expression(document.getElementById(";
            put "'" $id "'";
            put ").scrollWidth+22);";
         done;

         do /if $pageheight;
            eval  $pageh_ex upcase(reverse(substr(reverse($pageheight),1,1)));
            set $checknum 'ABCDEFGHIJKLMNOPQRSTUVWXYZ%';
            set $check_result verify($pageh_ex,$checknum);
            set $check_numeric "1";

            do / if cmp($check_result,"1");

                eval $pageheight cat($pageheight,"px");
                /*putlog $pageheight;*/
            done;

            put ";" /if $pagewidth;
            put " height:" $pageheight;
         else / if cmp($frozen_headers,"yes") and ^$pageheight;
            put ";" /if $pagewidth;
            put " height:expression(document.body.clientHeight-75);";

         done;

         put " "" ";
      done;

      put " id=""freeze"" ";

      trigger alt_align;
      put ">" NL;

      trigger pre_post;
      put "<table";
      put " onclick=sortCol(event) " /if cmp( $sort, "yes");
      putq " id=" $id;
      putq " class=" HTMLCLASS;

      trigger style_inline;

      do /if ^exists( $borders);
         putq " cellspacing=" CELLSPACING;
         putq " cellpadding=" CELLPADDING;
         putq " rules=" LOWCASE(RULES);
         putq " frame=" LOWCASE(FRAME);

      else /if cmp( $borders, "no");
         putq " rules=""none"" ";
         putq " frame=""void"" ";
         putq " cellspacing=""0"" ";
         putq " cellpadding=" CELLPADDING;

      else /if cmp( $borders, "rows");
         putq " cellspacing=""0""";
         putq " cellpadding=" CELLPADDING;
         putq " rules=""rows"" ";
         putq " frame=" LOWCASE(FRAME);
         putq " bordercolor=" $gridline_color;

      else /if cmp( $borders, "cols");
         putq " cellspacing=""0""";
         putq " cellpadding=" CELLPADDING;
         putq " rules=""cols"" ";
         putq " frame=" LOWCASE(FRAME);
         putq " bordercolor=" $gridline_color;
      done;

      trigger table_summary;
      put " onMouseOut=""javascript:highlightTable(0);"" " / if $highlight_color;
      put ">" NL;

      put $$excel_title;

      trigger user_caption / if $options["CAPTION_TEXT"];

      unset $options["CAPTION_TEXT" ];
      set $parent_table_spacing cellspacing;
      set $parent_table_padding cellpadding;

      /* Opening Excel Worksheet */

       trigger excel_options;
      do / if index($sheet_name,",") and $update_target;
         putlog "updating workbook" $update_target;
      else;

       do /if any( $excel_frozen_headers, $excel_sheet_prompt, $excel_save_prompt, $excel_save_dialog, $excel_autofilter,
                     $excel_orientation, $excel_table_move, $file_format, $excel_zoom,$excel_scale, $excel_save_file, $macro, $excel_default_width,
                     $excel_default_height, $query_file,$update_sheet, $update_target, $update_range,$ptsource_range, $ptdest_range, $pivotrow, $pivotcol,
                     $pivotdata, $pivotpage, $sheet, $insert_sheet, $chart_type, $chart_source, $auto_format, $auto_excel, $number_format,
                     $options["AUTO_FORMAT_SELECT"],$format_email,$sheet_interval,$chart_position,$chart_style,$chart_yaxes_numberformat,$chart_yaxes_maxscale,
                     $chart_yaxes_minscale,$worksheet_location,$worksheet_template,$pivot_format);
       set $excel_options "true";
       trigger file_format;
       trigger auto_format / if $auto_format;


       do / if !cmp($sheet_interval,"none");
          eval $xlsheet $xlsheet+1;
           /* putlog $xlsheet;*/
      done;

        do / if exist($excel_table_move);
          set $sheet_name scan($sheet_name,$test_count);
          set $id  scan($excel_table_move,$test_count);
            eval $mov_cnt count ($excel_table_move,",")+1;

            eval $id cat("id",$id);
            putlog $id;
            putlog $sheet_name;
            putlog $mov_cnt;
       else;
           eval $mov_cnt $test_count;
       done;


      do / if $test_count <= $mov_cnt;

      open xlstream ;
          put " var sheet = wb.ActiveSheet;" NL / if !cmp($sheet_interval,"none");
          eval $tid cat(" id",$id);
          putq "selectElementContents( document.getElementById(" $id "))" NL;
          put " document.execCommand(""copy"");" NL;

         /********************************************/
         /* Replacing MoveToElement fir Ie 10        */
         /* put " tr.moveToElementText(" $id ");" NL;*/
         /* put " tr.select();" NL;                  */
         /********************************************/

          put " document.execCommand(""copy"");" NL;

          /* Add templates */
          do / if  $update_sheet;
              putq " wb.Sheets(" $update_sheet ").Activate();" NL;
            else / if $worksheet_template;
              putq " var sheet = wb.Sheets.Add(after=wb.Sheets(wb.Sheets.Count),null,null," $worksheet_template ");"  NL / if !cmp($sheet_interval,"none");         else;
              put " var sheet = wb.Worksheets.Add(after=wb.Sheets(wb.Sheets.Count));" NL / if !cmp($sheet_interval,"none");
          done;

          put " var sheet = wb.ActiveSheet;" NL;

         do / if $sheet_name;
             set $store_sheet[] $sheet_name;
             eval $ncont[] event_name;
             eval $ncontx $ncont-1;


            do / if !cmp($store_sheet[$ncontx],$sheet_name);
               putq " sheet.Name=" $sheet_name ";" NL;
             else;
               eval $sheet_name cat($sheet_name,$ncont);
               putq " sheet.Name=" $sheet_name ";"  NL;
            done;
            else / if $update_sheet;
               eval $sheet_name $update_sheet;
               putq " sheet.Name=" $sheet_name ";"  NL;
            else;

             eval $sheet_name cat("Table_",$xlsheet);
             putq " sheet.Name=" $sheet_name ";" NL / if ^$update_sheet;
           done;

          putq " wb.Sheets(" $sheet_name ").Tab.ColorIndex = " $excel_tabcolor ";" NL /if $options['EXCEL_TABCOLOR'];

          trigger excelopt ;
          trigger num_lookup / if $number_format;
          trigger excelchart / if !cmp($pivotcharts,"yes");

          do / if ^$options['PIVOT_SERIES'];
             trigger pivot_tables_single /if any( $pivotrow, $pivotcol, $pivotpage,
                     $pivotdata);
          done;

          trigger excelchart / if cmp($pivotcharts,"yes");


          do / if $options['PIVOT_SERIES'];
              do /if index($pivotrow,"|");
                  eval $nums count($pivotrow,"|");
               else / if index($pivotcol,"|");
                  eval $nums count($pivotcol,"|");
               else / if index($pivotdata,"|");
                  eval $nums count($pivotdata,"|");
               else / if index($pivotpage,"|");
                  eval $nums count($pivotpage,"|");
               done;

               /*putlog "number of sheets " $nums; */
               eval $countx 0;

               do /while $countx <= $nums;
                  eval $countx $countx +1;
                 /* putlog "Countx=" $countx;*/
                  trigger pivot_tables;
               done;

              done;
            done;
         close;
       done;
     done;
    done;
  done;
done;
unset $cap;

   finish:
      unset $rowcount[event_name ];
      put "</table>" NL;

      trigger pre_post;
      put "</div>" NL;
      unset $filter_row;
      unset $rowcountx;
      unset $header_display;
      unset $col_high;
      unset $col_highc;
      unset $highcols;
      unset $hi;
      unset $radio;
      unset $r;
      unset $radio_cols;
      unset $options["RADIO" ];
      unset $options["DATA_TYPE"];
      unset $options["PIVOTPAGE"];
      unset $options["PIVOTROW"];
      unset $options["PIVOTCOL"];
      unset $options["PIVOTDATA"];
      unset $options["CHART_TYPE"];
      unset $$excel_title;

  end;

define event image;
   put "<div";
   put " class=";

   trigger alt_align;
   put ">" NL;
   put "<img";
   putq " alt=" alt;
   put " src=""";
   put BASENAME /if ^exists( NOBASE);
   put URL;
   put """";
   put " style=""" /if any( outputheight, outputwidth);
   put "height:" OUTPUTHEIGHT ";" /if exists( outputheight);
   put " width:" OUTPUTWIDTH ";" /if exists( outputwidth);
   put """" /if any( outputheight, outputwidth);
   put " border=""0""";
   put " usemap=""#" @CLIENTMAP;
   put " usemap=""#" NAME /if ^exists( @CLIENTMAP);
   put """" /if any( @CLIENTMAP, NAME);
   putq " id=" HTMLID;

   trigger classalign;
   put $empty_tag_suffix;
   put ">" NL;
   put "</div>" NL;
end;
define event pagebreak;
   break /if $web_tabs;

   do /if ^exists( $options["PAGEBREAK"]);
      put PAGEBREAKHTML NL /if ^exists( $endcol);
   done;


   do /if $options["PAGEBREAK"];
      set $tabpage $options["PAGEBREAK" ];
      eval $tabpage inputn($tabpage,"BEST");
      eval $pbcount[] event_name;
      /* eval $pbcount[event_name ] $pbcount[event_name ] +1;*/

      do /if mod($pbcount, $tabpage) = 0;
         put PAGEBREAKHTML NL /if ^cmp( $options["PAGEBREAK"], "no");
      done;

   done;

   do /if exists( $panelcols);
      eval $breakc[] event_name;
      /* eval $breakc[event_name ] $breakc[event_name ] +1; */
      set $r $breakc;
      set $s $endcol;
      eval $r inputn($r,"best");
      eval $s inputn($s,"best");
      put PAGEBREAKHTML /if $r >= $s;
   done;

end;
define event sub_header_colspec;

   do /if cmp( htmlclass, "RowHeader");
      set $foo[] "True";

   else;
      set $foo[] "False";
   done;

   do /if cmp( sasformat, "mmddyy") or cmp ( sasformat, "date") or cmp (sasformat, "MONYY");
      set $test6[] "true";

   else;
      set $test6[] "False";
   done;

   do / if cmp(sasformat,"dollar") or cmp(sasformat,"comma") or cmp(sasformat,"percent");
       set $test7[] "True";

   else;
      set $test7[] "False";
   done;


end;
define event table_head;
   put "<thead";
      eval $hid[] event_name;
      eval $head cat("hid",$hid);
      putq " id=" $head;
      put ">" NL;

   finish:
      put "</thead>" NL;
end;
define event table_body;
   put "<tbody";
      eval $bid[] event_name;
      /*eval $bid[event_name ] $bid[event_name ] +1;*/
      eval $bod cat("bid",$bid);
      putq " id=" $bod;
      put ">" NL;

   finish:

      do /if ^exist( $filter_row);
         put "</tbody>" NL;

      else;
         put "</tfoot>" NL;
      done;

end;
define event colspec_entry;
   eval $rowcountr[]  event_name;
   set $test[] scale;
   set $test1[] type;

   do /if cmp( sasformat, "mmddyy") or cmp ( sasformat, "date") or cmp (sasformat, "MONYY");
      set $test2[] "true";

   else;
      set $test2[] "False";
   done;

   set $test3[] precision;

   do /if cmp( sasformat, "dollar") or cmp ( sasformat, "comma") or cmp (sasformat, "percent");
      set $test4[] "true";

   else;
      set $test4[] "False";
   done;

   do /if cmp( sasformat,"F");
      set $test5[] "true";

   else;
      set $test5[] "False";
   done;

   set $align_cols $options['ALIGN_COLS'];
   set $absolute_column_width $options['ABSOLUTE_COLUMN_WIDTH'];

   put "<col";

   do /if cmp( $hide_cols, "yes");
      eval $colid cat("c",$rowcountr);
      putq " id=" $colid /if ^cmp( proc_name, "report");
   done;

   do / if any($align_cols,$absolute_column_width);
        set $align_cols scan($align_cols,$rowcountr);
        set $absolute_column_width scan($absolute_column_width,$rowcountr);

        put " style=""text-align:" $align_cols ";" "" / if ^cmp($align_cols," ");
        put " width:" $absolute_column_width """" /  if ^cmp($absolute_column_width," ");
  done;

   put $empty_tag_suffix;
   put ">" NL;
   unset $align_cols;


end;
define event align;
   break / if $script;
   do /if ^cmp( $excel_options, "true");
      trigger real_align start;
      trigger real_align finish;

   else;
      break;
   end;
   define event classalign;
      break / if $script;
      do /if ^cmp( $excel_options, "true");

         trigger real_align start;
         put " " htmlclass;

         trigger real_align finish;

      else;
         break /if ^htmlclass;
         put " class=""" htmlclass """";
      done;

   end;
   define event style_inline;
      break / if $script;
      do /if cmp( $excel_options, "true");
         put " " tagattr;
         break /if ^any( font_face, font_size, font_weight, font_style,
               foreground, background, backgroundimage, leftmargin,
               rightmargin, topmargin, bottommargin, bullet, outputheight,
               outputwidth, htmlstyle, indent, text_decoration, borderwidth,
               bordertopwidth, borderbottomwidth, borderrightwidth,
               borderleftwidth, bordercolor, bordertopcolor, borderbottomcolor,
               borderrightcolor, borderleftcolor, borderstyle,bordertopstyle, borderbottomstyle,
               borderrightstyle,borderleftstyle, just, vjust);
         put " style=""";
         put " font-family: " FONT_FACE;
         put ";" / exists( FONT_FACE);
         put " font-size: " FONT_SIZE;
         put ";" / exists( FONT_SIZE);
         put " font-weight: " FONT_WEIGHT;
         put ";" / exists( FONT_WEIGHT);
         put " font-style: " FONT_STYLE;
         put ";" / exists( FONT_STYLE);
         put " color: " FOREGROUND;
         put ";" / exists( FOREGROUND);
         put " text-decoration: " text_decoration;
         put ";" / exists( text_decoration);
         put " background-color: " BACKGROUND;
         put ";" / exists( BACKGROUND);
         put "  background-image: url('" BACKGROUNDIMAGE "')" /if exists(backgroundimage);
         put ";" / exists( BACKGROUNDIMAGE);
         put " margin-left: " LEFTMARGIN;
         put ";" / exists( LEFTMARGIN);
         put " margin-right: " RIGHTMARGIN;
         put ";" / exists( RIGHTMARGIN);
         put " margin-top: " TOPMARGIN;
         put ";" / exists( TOPMARGIN);
         put " margin-bottom: " BOTTOMMARGIN;
         put ";" / exists( BOTTOMMARGIN);
         put " text-indent: " indent;
         put ";" / exists( indent);

         trigger Border_inline;
         put " list_style_type: " BULLET;
         put ";" / exists( BULLET);
         put " height: " OUTPUTHEIGHT;
         put ";" / exists( OUTPUTHEIGHT);
         put " width: " OUTPUTWIDTH;
         put ";" / exists( OUTPUTWIDTH);
         put "text-align:" / exists( just);
         put $just_lookup[just ];
         put ";" / exists( just);
         put "vertical-align:" / exists( vjust);
         put $vjust_lookup[vjust ];
         put ";" / exists( vjust);
         put " " htmlstyle;
         put ";" / exists( htmlstyle);
         put """";

      else;
         put " " tagattr;
         break /if ^any( font_face, font_size, font_weight, font_style,
               foreground, background, backgroundimage, LEFTMARGIN,
               RIGHTMARGIN, TOPMARGIN, bottommargin, bullet, outputheight,
               outputwidth, htmlstyle, indent, text_decoration, borderwidth,
               bordertopwidth, borderbottomwidth, borderrightwidth,
               borderleftwidth, bordercolor, bordertopcolor, borderbottomcolor
               , borderrightcolor, borderleftcolor, borderstyle,
               bordertopstyle, borderbottomstyle, borderrightstyle,
               borderleftstyle);
         put " style=""";
         put " font-family: " FONT_FACE;
         put ";" / exists( FONT_FACE);
         put " font-size: " FONT_SIZE;
         put ";" / exists( FONT_SIZE);
         put " font-weight: " FONT_WEIGHT;
         put ";" / exists( FONT_WEIGHT);
         put " font-style: " FONT_STYLE;
         put ";" / exists( FONT_STYLE);
         put " color: " FOREGROUND;
         put ";" / exists( FOREGROUND);
         put " text-decoration: " text_decoration;
         put ";" / exists( text_decoration);
         put " background-color: " BACKGROUND;
         put ";" / exists( BACKGROUND);
         put "  background-image: url('" BACKGROUNDIMAGE "')" /if exists(backgroundimage);
         put ";" / exists( BACKGROUNDIMAGE);
         put " margin-left: " LEFTMARGIN;
         put ";" / exists( LEFTMARGIN);
         put " margin-right: " RIGHTMARGIN;
         put ";" / exists( RIGHTMARGIN);
         put " margin-top: " TOPMARGIN;
         put ";" / exists( TOPMARGIN);
         put " margin-bottom: " BOTTOMMARGIN;
         put ";" / exists( BOTTOMMARGIN);
         put " text-indent: " indent;
         put ";" / exists( indent);

         trigger Border_inline;
         put " list_style_type: " BULLET;
         put ";" / exists( BULLET);
         put " height: " OUTPUTHEIGHT;
         put ";" / exists( OUTPUTHEIGHT);
         put " width: " OUTPUTWIDTH;
         put ";" / exists( OUTPUTWIDTH);
         put " " htmlstyle;
         put ";" / exists( htmlstyle);
         put """";
      done;

   end;


   define event header;
      start:

         do /if cmp( $options["EXCLUDE_SUMMARY"], "yes");

            do /if cmp( htmlclass, "noFilter") and cmp ( colstart, "1");
               set $filter_row data_row;
               put "</tbody>" NL;
               put "<tfoot>" NL;
               put "<tr class=""noFilter"">" NL;
            done;

         done;

         break /if cmp( $header_display, "no");

         do /if cmp( section, "head");
          eval $hcount[] event_name;
          /*  eval $hcount[event_name ] $hcount[event_name ] +1; */
         done;


         do /if cmp( $options["EXCLUDE_SUMMARY"], "yes");
            put "<tr>" NL /if cmp( colstart, "1");
         done;

         put "<th";

         do / cmp( $options["REORDER_COLS"], "yes");

            do /if cmp( section, "head");
               put " colF=" $hcount /if cmp( section, "head");
               put " onMousedown=""MDN(this)"" onMouseup=""MUP(this)"" " NL;
            done;

         done;


         do /if cmp( $hide_cols, "yes");

            do /if cmp( section, "head");
               eval $hid cat("c",$hcount);

               do /if ^cmp( output_name, "Report");
                  put " OnDblClick=""test(" $hid ")""" /if ^cmp( output_name,"Report");

               else;
                  put " OnDblClick=""alert('Not supported with Report')"" ";
               done;

            done;

         done;


         do /if any( $frozen_rowheaders,$frozen_headers);

            do /if ^cmp( $id, "id1") or cmp ( section, "body") and cmp (htmlclass, "header");
               put " style=""position:static"" ";
            done;

         done;

         set $value[] colstart;

         do /if cmp( $frozen_rowheaders, "yes");

            do /if cmp( $foo[$value], "True");

               trigger real_align;
               put " rowheader header"" style=""z-index:50"" ";
            done;

         done;


         do /if ^cmp( $frozen_rowheaders, "yes");
            eval $frozrhc countc($frozen_rowheaders,",");
            eval $frozrhc $frozrhc +1;

            do /if $frozrhc > 0;
               eval $j 1;

               do /while $j <= $frozrhc;
                  set $row_freeze[] scan($frozen_rowheaders,$j);

                  trigger real_align /if cmp( $row_freeze[$j], colstart);

                do / if cmp(section,"head");
                      put " rowheader header"" style=""z-index:50"" " /if cmp($row_freeze[$j], colstart);
                  else;
                       put " rowheader "" " /if cmp($row_freeze[$j], colstart);
                  done;
                  eval $j $j +1;
               done;

            else;
               set $row_freeze[] scan($frozen_rowheaders,1);

               trigger real_align /if cmp( $row_freeze[1], colstart);
               put " rowheader header"" style=""z-index:50"" " /if cmp( $row_freeze[1], colstart);
            done;

         done;


         trigger classalign;
         putq " title=" flyover;


         trigger rowcol;

         do /if cmp( $sort, "yes") or cmp ( $describe , "yes");

            do /if cmp( section, "head");

                 put " title="" Sort by "  value """" / if cmp($options['SORT_FLYOVER'],"yes");

               do /if ^cmp( htmlclass, "rowheader");

                  do /if $options["DATA_TYPE"];
                     set $data_type scan($options["DATA_TYPE"],colstart);
                     set $data_type propcase($data_type);
                     putq " type=" $data_type /if ^cmp( $data_type, " ");
                  done;


                   do / if cmp(sysver,"9.1");
                      do / if cmp($test4[$value],"true"); /* or cmp($test5[$value],"true");*/
                          put " type=""Numberx""" / if ^exist(tagattr);
                      else / if cmp($test1[$value],"double");
                           put " type=""Number""" / if ^exist(tagattr);
                      else / if cmp($test2[$value],"true"); /* or cmp($test6[$value],"true");*/
                            put " type=""Date""" / if ^exist(tagattr);
                      else / if cmp($test5[$value],"true");
                            put " type=""Number""";
                      else;
                            put " type=""String""" / if ^exist(tagattr);
                      done;
                  else;
                     do / if cmp($test4[$value],"true") or cmp($test7[$value],"true");
                          put " type=""Numberx""" / if ^exist(tagattr);
                     else / if cmp($test1[$value],"double") and cmp($test6[$value],"false") ;
                           put " type=""Number""" / if ^exist(tagattr);
                    /* else / if cmp($test5[$value],"true");
                            put " type=""Number"""; */
                     else / if cmp($test6[$value],"true");
                           put " type=""Date""" / if ^exist(tagattr);
                     else;
                           put " type=""String""" / if ^exist(tagattr);
                     done;
                  done;


                 do / if cmp($options['DESCRIBE'],"yes");
                    do / if cmp(sysver,"9.1");
                       do / if cmp($test4[$value],"true"); /* or cmp($test5[$value],"true");*/
                           put  "><div style=""text-align:center;color:red;font-family:symbol"">%sysfunc(byte(168))</div" /if ^cmp( htmlclass, "rowheader");
                       else / if cmp($test1[$value],"double");
                             put  "><div style=""text-align:center;color:red;font-family:symbol"">%sysfunc(byte(168))</div" /if ^cmp( htmlclass, "rowheader");
                       else / if cmp($test2[$value],"true"); /* or cmp($test6[$value],"true");*/
                            put  "><div style=""text-align:center;color:red;font-family:wingdings"">6</div" /if ^cmp( htmlclass, "rowheader");
                       else / if cmp($test5[$value],"true");
                            put  "><div style=""text-align:center;color:red;font-family:symbol"">%sysfunc(byte(168))</div" /if ^cmp( htmlclass, "rowheader");
                       else;
                            put  "><div style=""text-align:center;color:blue;font-family:symbol"">%sysfunc(byte(183))</div" /if ^cmp( htmlclass, "rowheader");
                      done;
                  else;
                     do / if cmp($test4[$value],"true") or cmp($test7[$value],"true");
                         put  "><div style=""text-align:center;color:red;font-family:symbol"">%sysfunc(byte(168))</div" /if ^cmp( htmlclass, "rowheader");
                     else / if cmp($test1[$value],"double") and cmp($test6[$value],"false");
                         put  "><div style=""text-align:center;color:red;font-family:symbol"">%sysfunc(byte(168))</div" /if ^cmp( htmlclass, "rowheader");
                     else / if cmp($test2[$value],"true") or cmp($test6[$value],"true");
                         put  "><div style=""text-align:center;color:red;font-family:wingdings"">6</div" /if ^cmp( htmlclass, "rowheader");
                   /*  else / if cmp($test5[$value],"true");
                          put  "><div style=""text-align:center;color:red;font-family:symbol"">%sysfunc(byte(168))</div" /if ^cmp( htmlclass, "rowheader"); */
                     else;
                         put  "><div style=""text-align:center;color:blue;font-family:symbol"">%sysfunc(byte(183))</div" /if ^cmp( htmlclass, "rowheader");
                    done;
                   done;
                 done;
              done;
           done;
       done;


   trigger style_inline;
   put "  style=""" /if $header_vertical and cmp( section, "head");
   put " vertical-align:bottom;" /if contains( tagattr, "None") and cmp (section, "head");

   do /if cmp( $header_vertical, "yes") and cmp ( section, "head");
      put " layout-flow:vertical-ideographic;text-align:right;" /if cmp( $header_vertical, "yes");
   done;

   put """" /if $header_vertical and cmp( section, "head");
   put " nowrap" /if cmp( $options["NOWRAP"], "yes");
   put ">";

   do /if $sort_image and cmp( section, "head");

      do /if ^cmp( $data_type, "None");
         putq "<img src=" $sort_image ">" /if ^contains( tagattr, "None");
      done;

   done;


   do /if cmp( $sort_underline, "yes") and cmp ( section, "head");

      do /if ^cmp( $data_type, "None");
         putq "<span style=""text-decoration:underline;"">";
      done;

   done;

   trigger cell_value;

finish:

   trigger cell_value;
   put "</span>" /if $sort_underline and cmp( section, "head");
   put "</th>" NL;
   unset $frozrh;
   unset $j;
   unset $row_freeze;
end;
define event row;

   open rowtest /if cmp( $options["EXCLUDE_SUMMARY"], "yes");
      put "<tr";
      eval $rowcount[] event_name;
     /* eval $rowcount[event_name ] $rowcount[event_name ] +1; */


      do /if exist( $highlight_color);
         put " onmouseover=""javascript:highlightTable(this,";
         put "'" $highlight_color;
         put "');""";
      done;


      put ">" NL;
      close /if cmp( $options["EXCLUDE_SUMMARY"], "yes");

   finish:
      put "</tr>" NL;
      unset $foo;
      unset $value;
      unset $test;
      unset $test1;
      unset $test2;
      unset $rowcounty;
      unset $pivotpage;
  end;
  define event data;
   start:

      do /if cmp( $options["EXCLUDE_SUMMARY"], "yes");

         do /if ^cmp( htmlclass, "noFilter") and cmp ( colstart, "1");
            put "<tr>" NL;
         done;


         do /if cmp( htmlclass, "noFilter") and cmp ( colstart, "1");
            set $filter_row data_row;
            put "</tbody>" NL;
            put "<tfoot>" NL;
            put "<tr class=""noFilter"">" NL;
         done;

      done;


      trigger header /breakif cmp( htmlclass, "RowHeader");
      put "<td ";

      do /if ^cmp( $frozen_rowheaders, "yes");
         eval $frozrh countc($frozen_rowheaders,",");
         eval $frozrh $frozrh +1;
         eval $i 1;

         do /while $i <= $frozrh;
            set $row_freeze[] scan($frozen_rowheaders,$i);

            trigger real_align /if cmp( $row_freeze[$i], colstart);
            put " rowheader"" " /if cmp( $row_freeze[$i], colstart);
            eval $i $i +1;
         done;

      done;

      putq " title=" flyover;

      trigger classalign / if !any($banner_even,$banner_odd,$fbanner_even,$fbanner_odd,$col_even,$col_odd);

      trigger style_inline;

      trigger rowcol;

      do /if any( $banner_even, $banner_odd, $fbanner_odd, $fbanner_even);

         eval $data_row inputn(data_row,"best");
           do /if mod($data_row, 2);

             do /if any( $banner_odd, $fbanner_odd);
               do /if any( $col_even, $col_odd);
                 trigger real_align start;
                 put " "  htmlclass """";
                 put " style=""";
                 put "background-color:" $banner_odd ";" /if $banner_odd;
                 put "color:" $fbanner_odd;
                 put """";
               else;
                trigger real_align start;
                put " "  htmlclass;
                put " second""" ;
              done;
             else;
                trigger real_align start;
                put " "  htmlclass;
                put """" ;
            done;

           else;

           do /if any( $banner_even, $fbanner_even);
             do /if any( $col_even, $col_odd);
                trigger real_align start;
                 put " "  htmlclass """";
                 put " style=""";
                 put "background-color:" $banner_even ";" /if $banner_even;
                 put "color:" $fbanner_even;
                 put """";
             else;
                 trigger real_align start;
                 put " "  htmlclass;
                 put " first""" ;
              done;
             else;
                trigger real_align start;
                put " "  htmlclass;
                put """" ;
          done;
        done;
      done;

      do /if any( $col_even, $col_odd);
        trigger real_align start;
        put " "  htmlclass """";

         do /if $banner_odd and  ^ $banner_even;
            eval $rowcounty[] event_name;

            do /if mod($rowcounty, 2);
               put " style='background-color:" $col_odd "'" /if ^mod($data_row, 2) and $col_even;

            else;
               put " style='background-color:" $col_even "'" /if ^mod($data_row, 2) and $col_odd;
            done;

         done;


         do /if $banner_even and  ^ $banner_odd;
            eval $rowcounty[] event_name;

            do /if ^mod($rowcounty, 2);
               put " style='background-color:" $col_even "'" /if mod($data_row, 2) and $col_even;

            else;
               put " style='background-color:" $col_odd "'" /if mod($data_row, 2) and $col_odd;
            done;

         done;


         do /if ^any( $banner_even, $banner_odd);
            eval $rowcounty[] event_name;

            do /if ^mod($rowcounty, 2);
               put " style='background-color:" $col_even "'" /if $col_even;

            else;
               put " style='background-color:" $col_odd "'" /if $col_odd;
            done;

         done;

      done;


      eval $hi 0;

      do /if exists( $options["HIGHLIGHT_COLS"]);

         do /if ^any( $col_odd, $col_even);
            set $highlight_cols $options["HIGHLIGHT_COLS" ];
            eval $highcols countc($highlight_cols,",");
            eval $highcols $highcols +1;
            eval $hi $hi +1;

            do /if $highcols > 0;
               eval $j 1;

               do /while $j <= $highcols;
                  eval $col_high[] scan(scan($highlight_cols,$j,",") , 1 , "#" );
                  eval $col_highc[] scan(scan($highlight_cols,$j,",") , 2 , "#" );
                  put " style=""background-color:" $col_highc[$j ] ";""" /if  cmp( $col_high[$j], colstart);
                  eval $j $j +1;
               done;


            else;
               eval $col_high[] scan(scan($highlight_cols,$j) , 1 , "#" );
               eval $col_highc[] scan(scan($highlight_cols,$j) , 2 , "#" );
               put " style=""background-color:" $col_highc[$j ] ";""" /if cmp($col_high[1], colstart);
            done;

         done;

      done;

      put " nowrap" /if cmp( $options["NOWRAP"], "yes");
      put ">";


         do / if exists($options['RADIO']);
                set $radio $options['RADIO'] ;
                set $checked $options['RADIO_CHECKED'];
                eval $radioc countc($radio,",");
                eval $radioc $radioc+1;

                 eval $r 1;
                 do / while $r <= $radioc;
                    set $radio_cols[] scan($radio,$r);
                    set $radio_chk[] scan($checked,$r);
                    do / if cmp(value,$radio_chk[$r]);
                        put "<input type=""checkbox"" checked>"  / if cmp($radio_cols[$r],colstart);
                        else;
                        put "<input type=""checkbox"">"  / if cmp($radio_cols[$r],colstart);
                    done;
                   /* putlog $radio_cols[$r] colstart value;*/
                    eval $r $r+1;
                done;
           done;
       done;

   trigger cell_value;

finish:

   trigger header /breakif cmp( htmlclass, "RowHeader");

   trigger header /breakif cmp( htmlclass, "Header");

   trigger cell_value;
   put "</td>" NL;
   unset $frozrh;
   unset $i;
   unset $row_freeze;
   unset $highlight_cols;

end;
define event contents_bullet_style;
   put "<style type=""text/css"">" NL;
   put "<!--" NL;
   put "/* Outline Style Sheet */" NL NL;
   put ".Contents {background-color:" $options["TOC_BACKGROUND" ] ";" NL /if $options["TOC_BACKGROUND"];
   put "UL { cursor: hand;" NL;
   put "    list-style-type: decimal;}" NL NL;
   put "DL { cursor: hand;" NL;
   put "    list-style-type: none;}" NL NL;
   put "// so Netscape wont indent so far" NL;
   put "DL {marginLeft: -12pt}" NL NL;
   put "SPAN {cursor: hand}" NL;
   put ".expandable { " NL;
   put "list-style-image: ";

   do /if $options["OPEN_IMAGE_PATH"];
      put "url(";
      set $open_image_path $options["OPEN_IMAGE_PATH" ];
      put $open_image_path;
      put ");" NL;

   else;
      put "url(http://support.sas.com/rnd/base/ods/odsmarkup/tableeditor/plus.gif);" NL;
   done;

   put "}" NL;
   put ".leaf {" NL;
   put "list-style-image:";

   do /if $default_leaf_path;
      put $default_leaf_path;
      put ");" NL;
   done;

   put "list-style-type:none" nl;
   put "cursor: default;" NL;
   put "}" NL;
   put ".subList {" NL;
   put " display: none;" NL;
   put "}" NL;
   put "-->" NL;
   put "</style>" NL NL;
   put "</li>" NL;
end;
/* Test */
 define event contents_list;
     start:
          put "<";

          trigger list_tag;

         /* trigger listclass;  */
          put ">" NL;

         finish:
            put "</";

            trigger list_tag;
            put ">" NL;
   end;

define event contents_body;
   start:
      put "<body ";
      put " style=""background-color:" $options["TOC_BACKGROUND" ] """";
      putq " class=" HTMLCLASS;

      trigger style_inline / if cmp(sysver,"9.1");
      put ">" NL;

   finish:

      do /if cmp( $options["TOC_PRINT"], "yes");
         put "<script>" NL;
         put "function wprint() {" NL;
         put "parent.body.focus();" NL;
         put "parent.body.window.print()" NL;
         put "}" NL;
         put "</script>" NL;
         put "<input class=""button"" type=""button"" value=""Print"" onclick=""wprint()"" >"  NL;
      done;

      put "</body>" NL;
      putstream test2;
end;
define event listclass;
   putq " class=" HTMLCLASS;
end;
define event margins;
   put " text-indent: " indent;
   put " text-indent: " indent;
   put ";" NL / exists( indent);
   put ";" NL / exists( indent);
   put "  margin-left: " LEFTMARGIN;
   put ";" NL / exists( LEFTMARGIN);
   put "  margin-right: " RIGHTMARGIN;
   put ";" NL / exists( RIGHTMARGIN);
   put "  margin-top: " TOPMARGIN;
   put ";" NL / exists( TOPMARGIN);
   put "  margin-bottom: " BOTTOMMARGIN;
   put ";" NL / exists( BOTTOMMARGIN);
end;

/*******************************************************************/
/* Modified 4/8/2014 for the table of contents in SAS 9.4          */
/* To change the tag from OL to Ul so that the TOC works correctly */
/* when style added.                                               */
/*******************************************************************/


 define event list_tag;                                                  
         set $list_tag "ul";                                                  
         set $list_tag "ul" /if cmp( htmlclass, "contentfolder");             
         set $list_tag "ul" /if cmp( htmlclass, "bycontentfolder");           
         set $list_tag "ul" /if cmp( htmlclass, "contentprocname");           
         set $list_tag "ul" /if cmp( htmlclass, "contentproclabel");          
         set $list_tag "ul" /if cmp( htmlclass, "pagesitem");                 
         set $list_tag "ul" /if cmp( htmlclass, "contentitem");               
         set $list_tag "ul" /if cmp( liststyletype, "box");                   
         set $list_tag "ul" /if cmp( liststyletype, "check");                 
         set $list_tag "ul" /if cmp( liststyletype, "circle");                
         set $list_tag "ul" /if cmp( liststyletype, "diamond");               
         set $list_tag "ul" /if cmp( liststyletype, "disc");                  
         set $list_tag "ul" /if cmp( liststyletype, "hyphen");                
         set $list_tag "ul" /if cmp( liststyletype, "square");                
         put $list_tag;                                                       
 end;            

define event list_entry;
   start:
      unset $first_proc;
      set $first_proc "true" /if total_proc_count ne 1;
      put "<br>" /if exists( $first_proc, $proc_name);
      put "<li";

      do /if $options["TOC_BACKGROUND"];
         put " style=""background-color:" $options["TOC_BACKGROUND" ] """";
      done;


      do /if cmp( htmlclass, "contentprocname") or cmp ( htmlclass,"contentproclabel") or
             cmp ( htmlclass, "contentfolder") or  cmp( htmlclass, "bycontentfolder");
          put " class=""expandable"" " / if !cmp($options['TOC_EXPAND'],"yes");
          putq " class=" htmlclass  / if cmp($options['TOC_EXPAND'],"yes");

      else /if cmp( htmlclass, "contentitem");
         put " class=""leaf""" / if !cmp($options['TOC_EXPAND'],"yes");;
         putq " class=" htmlclass / if cmp($options['TOC_EXPAND'],"yes");;

      else;
         putq " class=" HTMLCLASS;
      done;

      put ">" NL;

      trigger do_link /if listentryanchor;

      trigger do_list_value /if ^listentryanchor;

   finish:
      put "</li>" NL;
end;
define event list;
   start:
      put "<";

      trigger list_tag;
      put " class=""sublist"" " /if ^cmp( $options["TOC_EXPAND"], "yes");
      put ">" NL;

   finish:
      put "</";

      trigger list_tag;
      put ">" NL;
end;
define event page_list;
   start:
      put "<";

      trigger list_tag;
      put " class=""sublist"" " /if ^cmp( $options["TOP_EXPAND"], "yes");
      put ">" NL;

   finish:
      put "</";

      trigger list_tag;
      put ">" NL;
   style = PagesItem;
end;

 define event contents_inline_code;

   /*trigger javascript_tag start; */

   trigger contents_code;

   trigger javascript_tag finish;
 end;


define event contents_code;
   trigger contents_bullet_style / if !cmp(sysver,"9.1");
   put "<script>" NL;
   put "var msie4=99;" NL;
   put "function getSubList (li) { " NL;
   put "var subList = null; " NL;
   put "for (var c = 0; c < li.childNodes.length; c++)" NL;
   put "if (li.childNodes[c].nodeName == 'UL') {" NL;
   put " subList = li.childNodes[c];" NL;
   put " break;" NL;
   put "}" NL;
   put " return subList;" NL;
   put "}" NL;
   put "function onClickHandler (evt) {" NL;
   put "var target = evt ? evt.target : event.srcElement;" NL;
   put "if (target.className == 'expandable') { //" NL;
   put "if (target.expanded) {" NL;
   put " target.style.listStyleImage =";

   do /if $open_image_path;
      put """url(";
      put $open_image_path;
      put ")"";" NL;

   else;
      put "'url(http://support.sas.com/rnd/base/ods/odsmarkup/tableeditor/plus.gif)';" NL;
   done;

   put " getSubList(target).style.display = 'none';" NL;
   put " target.expanded = false;" NL;
   put "}" NL;
   put " else {" NL;
   put " target.style.listStyleImage = ";

   do /if $options["CLOSED_IMAGE_PATH"];
      set $closed_image_path $options["CLOSED_IMAGE_PATH" ];
      put """url(";
      put $closed_image_path;
      put ")"";" NL;

   else;
      put "'url(http://support.sas.com/rnd/base/ods/odsmarkup/tableeditor/minus.gif)';" NL;
   done;

   put " getSubList(target).style.display = 'block';" NL;
   put " target.expanded = true;" NL;
   put "}" NL;
   put "}" NL;
   put "return true;" NL;
   put "}" NL;
   put "document.onclick = onClickHandler;" NL;
end;
define event reorder;
   put "<script>" NL;
   put "var colupdSW=0;" NL;
   put "function recol(listName, ncol, tocol) { " NL;
   put " var itocol   = parseInt(tocol) ; " NL;
   put " var incol    = parseInt(ncol)  ;" NL;
   put " if (itocol==incol) { return 0;} " NL;
   put " LastNewCol = -1; " NL;
   put " var oTable    = document.getElementById(listName);" NL;
   put " var nbRows    = oTable.children.length; " NL;
   put " var firstNode = oTable.children(0);" NL;
   put " for (var i=1; i<nbRows+1; i++) { " NL;
   put "    var curNode   = oTable.children(i-1); " NL;
   put "    var numTDs    = curNode.children.length; " NL;
   put "    if (  (itocol>numTDs-1)||(incol>numTDs-1)  )" NL;
   put "       { " NL;
   put "            var wscount = 0; " NL;
   put "            while((itocol>numTDs-1)||(incol>numTDs-1)) { " NL;
   put "                  var OnumTDs = numTDs ; " NL;
   put "                  curNode     = oTable.children(i-1); " NL;
   put "                  curNode.insertCell(numTDs);" NL;
   put "                  curNode     = oTable.children(i-1); " NL;
   put "                  numTDs      = curNode.children.length;" NL;
   put "                 wscount++; " NL;
   put "                  if (wscount>100) " NL;
   put "                       { " NL;
   put "                       alert('Row '+i+': Cells in Column Not Completely Populated - cannot move column \n too bad it\'s screwd up anyway'); " NL;
   put "                              bailout(cloudofdirtybytes) ;  " NL;
   put "                       } " NL;
   put "              } " NL;
   put "       } " NL;
   put "    var fstTDNode = curNode.children(itocol);  " NL;
   put "    var curTDNode = curNode.children(incol); " NL;
   put "    if(itocol<incol) " NL;
   put "       { " NL;
   put "         curNode.insertBefore(curTDNode, fstTDNode); " NL;
   put "    } else { " NL;
   put "         var fstTDNode = curNode.children(itocol); " NL;
   put "         var curTDNode = curNode.children(incol); " NL;
   put "         DOMNode_insertAfter(curTDNode, fstTDNode); " NL;
   put "       }  " NL;
   put "     for (var j=0; j<numTDs; j++)  { " NL;
   put "           curNode.children(j).colF=j ; " NL;
   put "    }  " NL;
   put "    } " NL;
   put " colupdSW= 1 ; " NL;
   put "  } " NL;
   put "function DOMNode_insertAfter(newChild,refChild) " NL;
   put "{" NL;
   put "var parentx=refChild.parentNode;" NL;
   put " if(parentx.lastChild==refChild) { return parentx.appendChild(newChild);} " NL;
   put " else {return parentx.insertBefore(newChild,refChild.nextSibling);} "    NL;
   put "}" NL;
   put "var x, y, z, col, fromcol; " NL;
   put "window.onload = init;" NL;
   put "z             = 0       ;" NL;
   put "col           = -9      ; " NL;
   put "fromcol       = -9      ;" NL;
   put "function init() { " NL;
   put "if (window.Event) {" NL;
   put "document.captureEvents(Event.MOUSEMOVE); " NL;
   put " } " NL;
   put "document.onmousemove = getXY; " NL;
   put "}" NL;
   put "function getXY(e) { " NL;
   put " x = (window.Event) ? e.pageX : event.clientX; " NL;
   put "y = (window.Event) ? e.pageY : event.clientY; " NL;
   put "if (lay1.style.display==' ')";
   put "{ lay1.style.top=y+9; lay1.style.left=x+4;} " NL;
   put "}" NL;
   put "function BlurHead()  { " NL;
   put "hid1.focus();" NL;
   put "}" NL;
   put "function MDN(el)  {" NL;
   put "z = 1; " NL;
   put "fromcol = el.colF;" NL;
   put "lay1.innerText = el.innerText; " NL;
   put "} " NL;
   put "function MUP(el)  {" NL;
   put " if(z==1) " NL;
   put " {  " NL;
   put "     col =el.colF ;  " NL;
   iterate $keepid;

   do /while _value_;
      eval $xvar substr(_value_,3);
      eval $tmpbod cat("bid",$xvar);
      eval $tmphd cat("hid",$xvar);
      putq "    recol(" $tmphd ", fromcol, col);" NL;
      putq "    recol(" $tmpbod ", fromcol, col);" NL;
      next $keepid;
   done;

   put " }" NL;
   put "z =0;" NL;
   put "lay1.style.display ='none'" NL;
   put " }" NL;
   put "</script>" NL;
end;
define event sort;
   put "var arrowU, arrowD;" NL;
   put "var _info = navigator.userAgent" NL;
   put "var _ie = (_info.indexOf(""MSIE"") > 0);" NL;
   put "initialize();" NL;
   put "function initialize() {" NL;
   put "if (_ie ) {" NL;

   put "      arrowU = document.createElement(""SPAN"");" NL;
   put "      var ad = document.createTextNode(""5"");" NL;
   put "      arrowU.appendChild(ad);" NL;
   put "      arrowU.style.fontFamily =""webdings"";" NL;
   putq "      arrowU.style.color=" $arrowcolor;
   put ";" NL /if exist( $arrowcolor);
   put "      arrowD = document.createElement(""SPAN"");" NL;
   put "      var ad = document.createTextNode(""6"");" NL;
   put "      arrowD.appendChild(ad);" NL;
   put "      arrowD.style.fontFamily=""webdings"";" NL;
   putq "      arrowD.style.color=" $arrowcolor;
   put ";" NL /if exist( $arrowcolor);
   put "}" NL;

   put "else {" NL;

   put "      arrowU = document.createElement(""SPAN"");" NL;
   put "      var ad = document.createTextNode("" "");" NL;
   put "      arrowU.appendChild(ad);" NL;
   put "      arrowU.style.fontFamily =""webdings"";" NL;
   putq "      arrowU.style.color=" $arrowcolor;
   put ";" NL /if exist( $arrowcolor);
   put "      arrowD = document.createElement(""SPAN"");" NL;
   put "      var ad = document.createTextNode("" "");" NL;
   put "      arrowD.appendChild(ad);" NL;
   put "      arrowD.style.fontFamily=""webdings"";" NL;
   putq "      arrowD.style.color=" $arrowcolor;
   put ";" NL /if exist( $arrowcolor);
   put "}" NL;
   put "}" NL;


   put "function sortTbl(tableNode, Col, Desc, cType) {" NL;
   put "      var tBody = tableNode.tBodies[0];" NL;
   put "      var trs = tBody.rows;" NL;
   put "      var trl= trs.length;" NL;
   put "      var a = new Array();" NL;
   put " for (var i = 0; i < trl; i++) {" NL;
   put " if (i==0) {continue} { " NL /if cmp( $autofilter, "yes");
   put "            a[i] = trs[i];" NL;
   put "      }" NL;
   put " }" NL /if cmp( $autofilter, "yes");
   put "      a.sort(compareCol(Col,Desc,cType));" NL;
   put "      for (var i = 0; i < trl; i++) {" NL;
   put "            tBody.appendChild(a[i]);" NL;
   put "      }" NL;
   put "}" NL;
   put "function parseDate(s) {" NL;
   put "return Date.parse(s.replace(/\-/g, '/'));" NL;
   put "}" NL;
   put NL;
   put "function compareCol(Col, Descending, cType) {" NL;
   put "      var c = Col;" NL;
   put "      var d = Descending;" NL;
   put "      if (cType == ""Number"")" NL;
   put "          fTypeCast = Number;" NL;
   put "      else if (cType == ""Date"")" NL;
   put "            fTypeCast = parseDate;" NL;
   put "      else if (cType == ""String"")" NL;
   put "            fTypeCast = String;" NL;
   put "      else if (cType == ""None"")" NL;
   put "            fTypeCast = Boolean;" NL;
   put "      else  fTypeCast = String;" NL;
   put " return function (n1, n2) {" NL;

   put "if (_ie ) {" NL;

   put "   var s1 = n1.cells[c].innerText;" NL;
   put "   var s2 = n2.cells[c].innerText;" NL;
   put "     if (cType == ""Numberx""){" NL;
   put "      var r1 = """";" NL;
   put "      var r2 = """";" NL;
   put "      fTypeCast = Number;" NL;
   put "       for (var i=0; i < s1.length; i++) {" NL;
   put %nrstr("         if %(s1.charAt%(i%) != '$' && ") NL;
   put %nrstr("             s1.charAt%(i%) != '%%' &&") NL;
   put %nrstr("                    s1.charAt(i) != ',') {") NL;
   put "                    r1 += s1.charAt(i);" NL;
   put " }" NL;
   put "         }" NL;
   put "           for (var i=0; i < s2.length; i++) {" NL;
   put %nrstr("                 if %(s2.charAt%(i%) != '$' &&") NL;
   put %nrstr("                      s2.charAt%(i%) != '%%' &&") NL;
   put %nrstr("                             s2.charAt(i) != ',') {") NL;
   put "                            r2 += s2.charAt(i);" NL;
   put "         }" NL;
   put "         }" NL;
   put " if (fTypeCast(r1) < fTypeCast(r2))" NL;
   put "         return d ? -1 : +1;" NL;
   put " if (fTypeCast(r1) > fTypeCast(r2))" NL;
   put "         return d ? +1 : -1;" NL;
   put "}" NL;
   put " else{" NL;
   put " if (fTypeCast(s1) < fTypeCast(s2))" NL;
   put "         return d ? -1 : +1;" NL;
   put " if (fTypeCast(s1) > fTypeCast(s2))" NL;
   put "         return d ? +1 : -1;" NL;
   put "}" NL;
   put "return 0;" NL;
   put "}" NL;

   put " else {" NL;

   put "if (fTypeCast(getInnerText(n1.cells[c])) < fTypeCast(getInnerText(n2.cells[c])))" NL;
   put "        return d ? -1 : +1;" NL;
   put "if (fTypeCast(getInnerText(n1.cells[c])) > fTypeCast(getInnerText(n2.cells[c])))" NL;
   put "        return d ? +1 : -1;" NL;
   put "    return 0;" NL;
   put "  }" NL;
   put " }" NL;
   put "}" NL;


   put "function sortCol(e) {" NL;
   put "  var tmp = e.target ? e.target : e.srcElement;" NL;
   put "  var tHeadParent = getParent(tmp, ""THEAD"");";
   put "  var el = getParent(tmp, ""TH"");" NL;
   put "   if (tHeadParent == null)" NL;
   put "      return;" NL;
   put "   if (el != null) {" NL;
   put "      var p = el.parentNode;" NL;
   put "      var i;" NL;
   put "        el._descending = !Boolean(el._descending);" NL;
   put "      if (tHeadParent.arrow != null) {" NL;
   put "            if (tHeadParent.arrow.parentNode != el) {" NL;
   put "                        tHeadParent.arrow.parentNode._descending = null;" NL;
   put "            }" NL;
   put "            tHeadParent.arrow.parentNode.removeChild(tHeadParent.arrow);" NL;
   put "      }" NL;
   put "      if (el._descending)" NL;
   put "            tHeadParent.arrow = arrowU.cloneNode(true);" NL;
   put "      else" NL;
   put "            tHeadParent.arrow = arrowD.cloneNode(true);" NL;
   put "    if (el.getAttribute(""type"")!=""None"") {" NL;
   put " el.appendChild(tHeadParent.arrow); }" NL;
   put "      var cells = p.cells;" NL;
   put "      var l = cells.length;" NL;
   put "      for (i = 0; i < l; i++) {" NL;
   put "            if (cells[i] == el) break;" NL;
   put "      }" NL;
   put "      var table = getParent(el, ""TABLE"");" NL;
   put "   sortTbl(table,i,el._descending, el.getAttribute(""type""));" NL;
   put "}" NL;
   put "}" NL;
   put "function getInnerText(el) {" NL;
   put "  var str = """";" NL;
   put "  var cs = el.childNodes;" NL;
   put "  var l = cs.length;" NL;
   put "    for (var i = 0; i < l; i++) {" NL;
   put "      switch (cs[i].nodeType) {" NL;
   put "            case 1: " NL;
   put "                  str += getInnerText(cs[i]);" NL;
   put "                       break;" NL;
   put "            case 3:" NL;
   put "                  str += cs[i].nodeValue;" NL;
   put "                  break;" NL;
   put "      }" NL;
   put "}" NL;
   put "return str;" NL;
   put "}" NL;
   put "function getParent(el, pTagName) {" NL;
   put "  if (el == null) return null;" NL;
   put %nrstr("  else if %(el.nodeType == 1 && el.tagName.toLowerCase%(%) == pTagName.toLowerCase%(%)%)") NL;
   put " return el;" NL;
   put "  else" NL;
   put "      return getParent(el.parentNode, pTagName);" NL;
   put "}" NL;
end;
define event autofilter;
   put "<SCRIPT language=javascript>" NL /if ^cmp( $sort, "yes");
   put "   function enableFilter()" NL;
   put "        {" NL;

   do /if $autofilter_table;
      eval $a_table cat("id",$autofilter_table);
      putq "      attachFilter(document.getElementById(" $a_table "), 1);" NL;

   else;
      iterate $keepid;

      do /while _value_;
         putq "      attachFilter(document.getElementById(" _value_ "), 1);"
               NL;
         next $keepid;
      done;

   done;

   put "        }" NL;
   put "function attachFilter(table, filterRow)" NL;
   put "{ " NL;
   put "    table.filterRow = filterRow;" NL;
   put "    if(table.rows.length > 0)" NL;
   put "    {" NL;
   put "        var filterRow = table.insertRow(table.filterRow);" NL;
   put "        for(var i = 0; i < table.rows[table.filterRow + 1].cells.length; i++)" NL;
   put "        {" NL;
   put "            if (i==" $autofilter_endcol ") {break}" NL /if $autofilter_endcol;
   put "            var c = document.createElement(""TH"");" NL;
   put "            table.rows[table.filterRow].appendChild(c);" NL;
   put "            var opt = document.createElement(""select"");" NL;
   put "            opt.onchange = filter;" NL;

   do /if ^$autofilter_width;
      put %nrstr("         opt.style.width=""100%%"";") NL;

   else;
      putq "         opt.style.width=" $autofilter_width ";" NL;
   done;

   put %nrstr("             c.style.zoom=""100%%""; ") NL;
   put "             c.style.height=""30""; " NL;
   put "             c.className=""Header""; " NL;
   put NL;
   put "             c.appendChild(opt);" NL;
   put "      }" NL;
   put "      table.fillFilters = fillFilters;" NL;
   put "      table.inFilter = inFilter;" NL;
   put "      table.buildFilter = buildFilter;" NL;
   put "      table.showAll = showAll;" NL;
   put "      table.filterElements = new Array();" NL;
   put "      table.fillFilters();" NL;
   put "      table.filterEnabled = true;" NL;
   put "  }" NL;
   put "}" NL;
   put "function inFilter(col)" NL;
   put "{" NL;
   put "  for(var i = 0; i < this.filterElements.length; i++)" NL;
   put "  {" NL;
   put "      if(this.filterElements[i].index == col)" NL;
   put "          return true;" NL;
   put "  }" NL;
   put "  return false;" NL;
   put "}" NL;
   put "function fillFilters()" NL;
   put "{" NL;
   put "  for(var col = 0; col < this.rows[this.filterRow].cells.length; col++)" NL;
   put "  {" NL;

   do /if $filter_cols;

      do /if index($filter_cols, ",");
         set $filter_value scan($filter_cols,1,",");
         eval $filcount 1;

         do /while ^cmp( $filter_value, " ");
            set $f_value[] strip($filter_value);
            eval $filcount $filcount +1;
            set $filter_value scan($filter_cols,$filcount,",");
         done;


      else;
         set $f_value[] strip($filter_cols);
      done;


      do /if ^contains( $filter_cols, ",");
         eval $addfilter inputn($filter_cols,"Best") -1;
         put "if (col !=" $addfilter " ) {continue}" NL;

      else;
         eval $filend $filcount -1;
         iterate $f_value;
         eval $filec 1;
         put " if (";

         do /while _value_;
            put " col != ";
            eval $addfilter1 inputn(_value_,"Best") -1;
            put $addfilter1;
            put %nrstr(" && ") /if $filec < $filend;
            eval $filec $filec +1;
            next $f_value;
         done;

         put " ) {continue}" NL;
      done;

   done;

   put "      if(!this.inFilter(col))" NL;
   put "      {" NL;
   put "          this.buildFilter(col, ""(all)"");" NL;
   put "      }" NL;
   put "  }" NL;
   put "}" NL;
   put "function buildFilter(col, setValue)" NL;
   put "{" NL;
   put "  var opt = this.rows[this.filterRow].cells[col].firstChild;" NL;
   put "  while(opt.length > 0)" NL;
   put "      opt.remove(0);" NL;
   put "  var values = new Array();" NL;
   put "  for(var i = this.filterRow + 1; i < this.rows.length; i++)" NL;
   put "  {" NL;
   put "      var row = this.rows[i];" NL;
   put %nrstr("      if%(row.style.display != ""none"" & row.className != ""noFilter""%)") NL;
   put "      {" NL;
   put "          values.push(row.cells[col].innerHTML.toLowerCase());" NL;
   put "      }" NL;
   put "  }" NL;
   put "  values.sort();" NL;
   put "  var value;" NL;
   put "  for(var i = 0; i < values.length; i++)" NL;
   put "  {" NL;
   put "      if(values[i].toLowerCase() != value)" NL;
   put "      {" NL;
   put "          value = values[i].toLowerCase();" NL;
   put "          opt.options.add(new Option(values[i], value));" NL;
   put "      }" NL;
   put "  }" NL;
   put "  opt.options.add(new Option(""(all)"", ""(all)""), 0);" NL;
   put "  if(setValue != undefined)" NL;
   put "      opt.value = setValue;" NL;
   put "  else" NL;
   put "      opt.options[0].selected = true;" NL;
   put "}" NL;
   put "function filter()" NL;
   put "{" NL;
   put "  var table = this; // 'this' is a reference to the dropdownbox which changed" NL;
   put "  while(table.tagName.toUpperCase() != ""TABLE"")" NL;
   put "      table = table.parentNode;" NL;
   put "  var filterIndex = this.parentNode.cellIndex; // The column number of the column which should be filtered" NL;
   put "  var filterText = table.rows[table.filterRow].cells[filterIndex].firstChild.value;" NL;
   put "  var bFound = false;" NL;
   put "  for(var i = 0; i < table.filterElements.length; i++)" NL;
   put "  {" NL;
   put "      if(table.filterElements[i].index == filterIndex)" NL;
   put "      {" NL;
   put "          bFound = true;" NL;
   put "          if(filterText == ""(all)"")" NL;
   put "          {" NL;
   put "              table.filterElements.splice(i, 1);" NL;
   put "          }" NL;
   put "          else" NL;
   put "          {" NL;
   put "              table.filterElements[i].filter = filterText;" NL;
   put "          }" NL;
   put "          break;" NL;
   put "      }" NL;
   put "  }" NL;
   put "  if(!bFound)" NL;
   put "  {" NL;
   put "      var obj = new Object();" NL;
   put "      obj.filter = filterText;" NL;
   put "      obj.index = filterIndex;" NL;
   put "      table.filterElements.push(obj);" NL;
   put "  }" NL;
   put "  table.showAll();" NL;
   put "  for(var i = 0; i < table.filterElements.length; i++)" NL;
   put "  {" NL;
   put "      table.buildFilter(table.filterElements[i].index, table.filterElements[i].filter);" NL;
   put "      for(var j = table.filterRow + 1; j < table.rows.length; j++)" NL;
   put "      {" NL;
   put "          var row = table.rows[j];" NL;
   put %nrstr("          if%(table.style.display != ""none"" && row.className != ""noFilter""%)") NL;
   put "          {" NL;
   put "              if(table.filterElements[i].filter != row.cells[table.filterElements[i].index].innerHTML.toLowerCase())" NL;
   put "              {" NL;
   put "                  row.style.display = ""none"";" NL;
   put "              }" NL;
   put "          }" NL;
   put "      }" NL;
   put "  }" NL;
   put "  table.fillFilters();" NL;
   put "}" NL;
   put "function showAll()" NL;
   put "{" NL;
   put "  for(var i = this.filterRow + 1; i < this.rows.length; i++)" NL;
   put "  {" NL;
   put "      this.rows[i].style.display = """";" NL;
   put "  }" NL;
   put "}" NL;
   put "</SCRIPT>";
 done;
end;

define event highlight;
  put "<script>" NL;
  put "var savedStates=new Array();" NL;
  put "var savedStateCount=0;" NL;
  put "function saveBackgroundStyle(myElement)" NL;
  put "{" NL;
  put "saved=new Object();" NL;
  put "saved.element=myElement;" NL;
  put "saved.className=myElement.className;" NL;
  put "saved.backgroundColor=myElement.style[""backgroundColor""];" NL;
  put "return saved;" NL;
  put "}" NL;
  put "function restoreBackgroundStyle(savedState)" NL;
  put "{" NL;
  put "savedState.element.style[""backgroundColor""]=savedState.backgroundColor;" NL;
  put "if (savedState.className)" NL;
  put "{" NL;
  put "savedState.element.className=savedState.className;" NL;
  put "}" NL;
  put "}" NL;
  put "function findNode(startingNode, tagName)" NL;
  put "{" NL;
  put "myElement=startingNode;" NL;
  put "var i=0;" NL;
  put "while (myElement %nrstr(&&) (!myElement.tagName || (myElement.tagName %nrstr(&&) myElement.tagName!=tagName)))" NL;
  put "{" NL;
  put "myElement=startingNode.childNodes[i];" NL;
  put "i++;" NL;
  put "} " NL;
  put "if (myElement %nrstr(&&) myElement.tagName %nrstr(&&) myElement.tagName==tagName)" NL;
  put "{" NL;
  put "return myElement;" NL;
  put "}" NL;
  put "else if (startingNode.firstChild)" NL;
  put "return findNode(startingNode.firstChild, tagName);" NL;
  put "return 0;" NL;
  put "}" NL;
  put "function highlightTable(myElement, highlightColor)" NL;
  put "{" NL;
  put "  var i=0;" NL;
  put "  for (i; i<savedStateCount; i++)" NL;
  put "  {" NL;
  put "    restoreBackgroundStyle(savedStates[i]); " NL;
  put "  }" NL;
  put "  savedStateCount=0;" NL;
  put "  if (!myElement || (myElement %nrstr(&&) myElement.id && myElement.id==""header"") )" NL;
  put "    return;" NL;
  put "  if (myElement)" NL;
  put "  {" NL;
  put "    var tableRow=myElement;" NL;
  put "    if (tableRow)" NL;
  put "    {" NL;
  put "      savedStates[savedStateCount]=saveBackgroundStyle(tableRow);" NL;
  put "      savedStateCount++;" NL;
  put "    }" NL;
  put "    var tableCell=findNode(myElement, ""TD""); " NL;
  put "    i=0;" NL;
  put "    while (tableCell) " NL;
  put "    {" NL;
  put "      if (tableCell.tagName==""TD"") " NL;
  put "      { " NL;
  put "        if (!tableCell.style) " NL;
  put "        { " NL;
  put "          tableCell.style={}; " NL;
  put "        }" NL;
  put "        else " NL;
  put "        { " NL;
  put "          savedStates[savedStateCount]=saveBackgroundStyle(tableCell); " NL;
  put "          savedStateCount++; " NL;
  put "        } " NL;
  put "        tableCell.style[""backgroundColor""]=highlightColor; " NL;
  put "        tableCell.style.cursor='default'; " NL;
  put "        i++; " NL;
  put "      }" NL;
  put "      tableCell=tableCell.nextSibling; " NL;
  put "    } " NL;
  put "  } " NL;
  put "} " NL;
  put "function findNode(startingNode, tagName) " NL;
  put "{" NL;
  put "  myElement=startingNode;" NL;
  put "  var i=0; " NL;
  put "  while (myElement %nrstr(&&) " NL;
  put "    (!myElement.tagName || (myElement.tagName %nrstr(&&) myElement.tagName!=tagName))) " NL;
  put "  { " NL;
  put "    myElement=startingNode.childNodes[i++]; " NL;
  put "  } " NL;
  put "  if (myElement %nrstr(&&) myElement.tagName %nrstr(&&) myElement.tagName==tagName) " NL;
  put "  { " NL;
  put "    return myElement; " NL;
  put "  } " NL;
  put "  // On Internet Explorer, the <tr> node might be the firstChild node of the <tr> node " NL;
  put "  else if (startingNode.firstChild) " NL;
  put "    return findNode(startingNode.firstChild, tagName); " NL;
  put "  return 0; " NL;
  put "}" NL;
  put "</script>" NL;
end;

 define event alignstyle;
        break / if $script;
         putl ".l {text-align: left }";
         putl ".c {text-align: center }";
         putl ".r {text-align: right }";
         putl ".d {text-align: right }";
         putl ".j {text-align: justify }";
         putl ".t {vertical-align: top }";
         putl ".m {vertical-align: middle }";
         putl ".b {vertical-align: bottom }";
         putl "TD, TH {vertical-align: top }";
         putl ".stacked_cell{padding: 0 }";
    end;

    define event doc_title;
         break / if $script;
         put "<title>";
         put "SAS Output" /if ^exists( VALUE);
         put VALUE;
         put "</title>" NL;
    end;

    define event doc_meta;
         break / if $script;
         put "<meta name=""Generator"" content=""SAS Software";
         set $generic getoption("generic");
         put " Version " SASVERSION /if cmp( $generic, "NOGENERIC");
         put ", see www.sas.com""";
         put $empty_tag_suffix;
         put ">" NL;

         trigger show_charset;
         put "<meta " VALUE $empty_tag_suffix ">" NL /if exists( value);
         break /if ^any( htmlcontenttype, encoding);
         break /if ^exists( htmlcontenttype) and  ^ exists ( $show_charset );
         put "<meta";
         put " http-equiv=""Content-type"" content=""";
         put HTMLCONTENTTYPE;
         put "; " /if exists( HTMLCONTENTTYPE, encoding, $show_charset);
         put "charset=" encoding /if exists( $show_charset);
         put """";
         put $empty_tag_suffix;
         put ">" NL;
    end;

    define event javascript;
         start:
            break / if $script;

            put "<script language=""javascript"" type=""text/javascript"">" NL;
            put "<!-- " NL;

         finish:
            break / if $script;

            put NL "//-->" NL;
            put "</script>" NL NL;
 end;

 define event shutdown_function;
   start:
       break / if $script;
       put "function shutdown(){" NL NL;

   finish:
       put TAGATTR NL;
       put "}" NL / if !$script;
 end;

 define event preformatted;
    start:
       break / if $script;
       put "<pre";
       putq " class=" htmlclass;
       put "//";
       trigger style_inline / if !$script;
       put ">";

    finish:
       put "</pre>" / if !$script;
  end;

  define event verbatim_text;
      break / if $script;
      put value;
      put NL;
  end;

  define event anchor;
         break / if $script;
         putq "<a name=" NAME "></a>" NL /if length(NAME);
  end;
parent = tagsets.html4;
end;


define style styles.MyStyle;
    parent=styles.default;
      replace container /
        font_size=10pt;
      style body from body /
        background=_undef_;
      style header from header /
        background=beige
        bordertopwidth=1px
        bordertopstyle=solid
        bordertopcolor=#ffffff
        borderleftwidth=0px
        bordertopstyle=solid
        borderrightwidth=1px
        borderrightcolor=#666666
        borderrightstyle=solid
        borderbottomwidth=1px
        borderbottomcolor=#666666
        borderbottomstyle=solid
        font_weight=bold
        foreground=#003366
        font_face=verdana;
    style rowheader from header;
    style data from data /
          htmlstyle="border:1px solid beige;"
          background=_undef_;
    style table from table /
          background=_undef_;
    style systemtitle from systemtitle /
          foreground=#003366
          background=_undef_;
    style systemfooter from systemtitle;
    style byline from byline /
          background=_unfef_;
    style dataemphasis from dataemphasis /
         background=_undef_;
        style contentprocname from contentprocname /
              htmlclass="expandable";
        style contentfolder from contentfolder /
              htmlclass="expandable";
        style bycontentfolder from bycontentfolder /
              htmlclass="expandable";
        style contentitem from contentitem /
              htmlclass="leaf";

        style proctitle from proctitle /
              background=_undef_;
   end;
run;




