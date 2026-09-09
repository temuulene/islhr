# only the taught API is exported

    Code
      cat(exports, sep = "\n")
    Output
      coord_islh_map
      islh_brand
      islh_brand_yml
      islh_caption
      islh_check
      islh_check_project
      islh_create_report
      islh_epi_curve
      islh_example_data
      islh_example_plot
      islh_flextable
      islh_font_family
      islh_gt
      islh_gtsummary_flex
      islh_gtsummary_gt
      islh_gtsummary_statistics
      islh_help
      islh_hex
      islh_install_deps
      islh_logo
      islh_reference_docx
      islh_reset
      islh_save_plot
      islh_setup
      islh_update_project
      islh_use_brand
      islh_use_quarto
      islh_version
      scale_color_islh
      scale_color_islh_ordinal
      scale_color_islh_signal
      scale_colour_islh
      scale_colour_islh_ordinal
      scale_colour_islh_signal
      scale_fill_islh
      scale_fill_islh_b
      scale_fill_islh_ordinal
      scale_fill_islh_signal
      scale_y_islh_count
      theme_islh
      theme_islh_map
      with_islh

# islh_help prints a grouped quick reference

    Code
      islh_help()
    Output
      Island Health theme 0.6.1
      
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
        islh_gtsummary_statistics()   opt in to summary display defaults
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

