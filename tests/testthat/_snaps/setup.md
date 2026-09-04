# only the taught API is exported

    Code
      exports
    Output
       [1] "coord_islh_map"            "islh_brand"               
       [3] "islh_brand_yml"            "islh_caption"             
       [5] "islh_check"                "islh_create_report"       
       [7] "islh_example_data"         "islh_example_plot"        
       [9] "islh_flextable"            "islh_font_family"         
      [11] "islh_gt"                   "islh_gtsummary_flex"      
      [13] "islh_gtsummary_gt"         "islh_help"                
      [15] "islh_hex"                  "islh_install_deps"        
      [17] "islh_logo"                 "islh_reference_docx"      
      [19] "islh_save_plot"            "islh_setup"               
      [21] "islh_use_brand"            "islh_use_quarto"          
      [23] "islh_version"              "scale_color_islh"         
      [25] "scale_color_islh_ordinal"  "scale_color_islh_signal"  
      [27] "scale_colour_islh"         "scale_colour_islh_ordinal"
      [29] "scale_colour_islh_signal"  "scale_fill_islh"          
      [31] "scale_fill_islh_b"         "scale_fill_islh_ordinal"  
      [33] "scale_fill_islh_signal"    "scale_y_islh_count"       
      [35] "theme_islh"                "theme_islh_map"           

# islh_help prints a grouped quick reference

    Code
      islh_help()
    Output
      Island Health theme 0.4.0
      
      SETUP  once per document or session
        islh_setup()                  apply the theme; detects HTML or Word
        islh_check()                  list any packages you still need
      
      FIGURES  islh_setup() already applies the theme, so plot as usual
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
      
      SEE IT WORK
        islh_example_plot()                 a themed plot from simulated data
      

