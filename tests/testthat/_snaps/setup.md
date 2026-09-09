# only the taught API is exported

    Code
      exports
    Output
       [1] "coord_islh_map"            "islh_brand"               
       [3] "islh_brand_yml"            "islh_caption"             
       [5] "islh_check"                "islh_check_project"       
       [7] "islh_create_report"        "islh_epi_curve"           
       [9] "islh_example_data"         "islh_example_plot"        
      [11] "islh_flextable"            "islh_font_family"         
      [13] "islh_gt"                   "islh_gtsummary_flex"      
      [15] "islh_gtsummary_gt"         "islh_help"                
      [17] "islh_hex"                  "islh_install_deps"        
      [19] "islh_logo"                 "islh_reference_docx"      
      [21] "islh_reset"                "islh_save_plot"           
      [23] "islh_setup"                "islh_update_project"      
      [25] "islh_use_brand"            "islh_use_quarto"          
      [27] "islh_version"              "scale_color_islh"         
      [29] "scale_color_islh_ordinal"  "scale_color_islh_signal"  
      [31] "scale_colour_islh"         "scale_colour_islh_ordinal"
      [33] "scale_colour_islh_signal"  "scale_fill_islh"          
      [35] "scale_fill_islh_b"         "scale_fill_islh_ordinal"  
      [37] "scale_fill_islh_signal"    "scale_y_islh_count"       
      [39] "theme_islh"                "theme_islh_map"           
      [41] "with_islh"                

# islh_help prints a grouped quick reference

    Code
      islh_help()
    Output
      Island Health theme 0.6.0
      
      SETUP  once per document or session
        islh_setup()                  apply the theme; detects HTML or Word
        islh_reset()                  put the session back as it was
        with_islh({ ... })            apply it around one block only
        islh_check()                  list any packages you still need
      
      FIGURES  islh_setup() already applies the theme, so plot as usual
        islh_epi_curve(data, date, count)  a routine surveillance curve
        scale_fill_islh()             colours for categories
        scale_colour_islh()           the same, for lines and points
        scale_fill_islh_ordinal()     low to high within one colour
        scale_fill_islh_signal()      red, orange, green for status
        scale_y_islh_count()          count axis with thousands separators
        theme_islh(base_size = 12)    the theme on its own, for one plot
      
      MAPS
        theme_islh_map()              map theme with no chart furniture
        theme_islh_map(legend = "inside")   legend in the open water
        coord_islh_map()              BC Albers, no graticule
        scale_fill_islh_b()           binned fill for a choropleth
        islh_caption(source, extracted)     source, date, suppression rule
      
      COLOURS
        islh_brand("primary")         the main Island Health blue
        islh_hex("blue", 40)          any step of any colour family
      
      TABLES
        islh_gt(data)                 HTML
        islh_flextable(data)          Word
        both fill the text width; use width = 0.6 for a narrower table
      
      SAVING A FIGURE
        islh_save_plot("figure.png")  standard report size
        islh_save_plot("f.png", preset = "slide")
      
      STARTING A REPORT
        islh_create_report("my-report", format = "docx")
        islh_install_deps("docx")           install what the format needs
      
      KEEPING A REPORT UP TO DATE
        islh_check_project()                what is out of date or edited
        islh_update_project()               bring in the current files
      
      SEE IT WORK
        islh_example_plot()                 a themed plot from simulated data
