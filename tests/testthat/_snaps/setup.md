# only the taught API is exported

    Code
      exports
    Output
       [1] "islh_age_group"            "islh_brand"               
       [3] "islh_brand_yml"            "islh_check"               
       [5] "islh_ci_poisson"           "islh_create_report"       
       [7] "islh_crude_rate"           "islh_dsr"                 
       [9] "islh_example_data"         "islh_example_plot"        
      [11] "islh_flextable"            "islh_font_family"         
      [13] "islh_gt"                   "islh_gtsummary_flex"      
      [15] "islh_gtsummary_gt"         "islh_help"                
      [17] "islh_hex"                  "islh_install_deps"        
      [19] "islh_logo"                 "islh_reference_docx"      
      [21] "islh_round_base"           "islh_save_plot"           
      [23] "islh_setup"                "islh_suppress"            
      [25] "islh_suppress_table"       "islh_use_brand"           
      [27] "islh_use_quarto"           "islh_version"             
      [29] "scale_color_islh"          "scale_color_islh_ordinal" 
      [31] "scale_color_islh_signal"   "scale_colour_islh"        
      [33] "scale_colour_islh_ordinal" "scale_colour_islh_signal" 
      [35] "scale_fill_islh"           "scale_fill_islh_b"        
      [37] "scale_fill_islh_ordinal"   "scale_fill_islh_signal"   
      [39] "scale_y_islh_count"        "theme_islh"               

# islh_help prints a grouped quick reference

    Code
      islh_help()
    Output
      Island Health theme 0.1.0
      
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
      
      SMALL COUNTS
        islh_suppress(n, threshold = 5)     set the threshold your data needs
        islh_suppress_table(data, cols, threshold = 5)
        islh_round_base(n, base = 5)        round instead of suppressing
      
      RATES
        islh_age_group(age)                 standard age bands
        islh_crude_rate(cases, population)
        islh_dsr(cases, population, std_population)
        islh_ci_poisson(count)
      
      STARTING A REPORT
        islh_create_report("my-report", format = "docx")
        islh_install_deps("docx")           install what the format needs
      
      SEE IT WORK
        islh_example_plot()                 a themed plot from simulated data
      

