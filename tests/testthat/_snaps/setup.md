# only the taught API is exported

    Code
      exports
    Output
       [1] "coord_islh_map"            "islh_areas"               
       [3] "islh_brand"                "islh_brand_yml"           
       [5] "islh_caption"              "islh_check"               
       [7] "islh_check_project"        "islh_create_report"       
       [9] "islh_epi_curve"            "islh_example_data"        
      [11] "islh_example_plot"         "islh_flextable"           
      [13] "islh_font_family"          "islh_gt"                  
      [15] "islh_gtsummary_flex"       "islh_gtsummary_gt"        
      [17] "islh_help"                 "islh_hex"                 
      [19] "islh_install_deps"         "islh_logo"                
      [21] "islh_reference_docx"       "islh_reset"               
      [23] "islh_save_plot"            "islh_setup"               
      [25] "islh_update_project"       "islh_use_brand"           
      [27] "islh_use_quarto"           "islh_version"             
      [29] "scale_color_islh"          "scale_color_islh_area"    
      [31] "scale_color_islh_ordinal"  "scale_color_islh_signal"  
      [33] "scale_colour_islh"         "scale_colour_islh_area"   
      [35] "scale_colour_islh_ordinal" "scale_colour_islh_signal" 
      [37] "scale_fill_islh"           "scale_fill_islh_area"     
      [39] "scale_fill_islh_b"         "scale_fill_islh_ordinal"  
      [41] "scale_fill_islh_signal"    "scale_y_islh_count"       
      [43] "theme_islh"                "theme_islh_map"           
      [45] "with_islh"                

# islh_help prints a grouped quick reference

    Code
      islh_help()
    Output
      Island Health theme 0.8.0
      
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
        scale_fill_islh_area()        a fixed colour for each of the 14 LHAs
        islh_areas("lha")             LHA codes, names, HSDAs and colours
        islh_caption(source, extracted)     source, date, suppression rule
      
      COLOURS AND LOGOS
        islh_brand("primary")         the main Island Health blue
        islh_hex("blue", 40)          any step of any colour family
        islh_logo("horizontal")       path to a logo file
      
      TABLES
        islh_gt(data)                 HTML
        islh_flextable(data)          Word
        islh_gtsummary_gt(tbl)        a gtsummary table, for HTML
        islh_gtsummary_flex(tbl)      a gtsummary table, for Word
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

