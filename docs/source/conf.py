# Configuration file for the Sphinx documentation builder.
#
# This file only contains a selection of the most common options. For a full
# list see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Path setup --------------------------------------------------------------

# If extensions (or modules to document with autodoc) are in another directory,
# add these directories to sys.path here. If the directory is relative to the
# documentation root, use os.path.abspath to make it absolute, like shown here.
#
# import os
# import sys
# sys.path.insert(0, os.path.abspath('.'))


# -- Project information -----------------------------------------------------

project = 'Modern Fortran in Science and Technology'
copyright = '2020-2022, Jonas Lindemann and Ola Dahlblom'
author = 'Jonas Lindemann and Ola Dahlblom'

# The full version, including alpha/beta/rc tags
release = '1.1'


# -- General configuration ---------------------------------------------------

# Add any Sphinx extension module names here, as strings. They can be
# extensions coming with Sphinx (named 'sphinx.ext.*') or your custom
# ones.
extensions = [
    'sphinx.ext.imgconverter',
    'sphinx_copybutton',
    'sphinx_design'
    ]

image_converter = "C:\Program Files\ImageMagick-7.0.10-Q16-HDRI\magick.exe"
image_converter_args=["-density", "300"]

numfig = True

# Add any paths that contain templates here, relative to this directory.
templates_path = ['_templates']

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
# This pattern also affects html_static_path and html_extra_path.
exclude_patterns = []


# -- Options for HTML output -------------------------------------------------

# The theme to use for HTML and HTML Help pages.  See the documentation for
# a list of builtin themes.
#
html_theme = 'shibuya'

html_title = 'Modern Fortran in Science and Technology'
html_show_sourcelink = True

html_logo = "_static/Fortran_logo.svg"

# Shibuya builds the global table of contents into its own left sidebar, so
# only the right-hand sidebar is configured here.
html_sidebars = {
    "**": ["sidebars/localtoc.html", "sidebars/edit-this-page.html"]
}

html_theme_options = {

    # Colour scheme. The top bar itself is tinted a translucent #734f96 in
    # _static/custom.css via the --sy-c-background-dropback variable.
    'accent_color': 'blue',
    'color_mode': 'auto',

    # Header navigation.
    'nav_links': [
        {'title': 'Fortran', 'url': 'chapter_fortran'},
        {'title': 'Python', 'url': 'chapter_fortran_python'},
        {'title': 'Projects', 'url': 'chapter_fortran_projects'},
        {'title': 'Exercises', 'url': 'app_exercises'},
    ],

    # Repository, shown as an icon in the header and used for
    # the "Edit this page" link.
    'github_url': 'https://github.com/jonaslindemann/modern_fortran_book',

    # Global table of contents in the left sidebar.
    'toctree_collapse': False,
    'toctree_maxdepth': 2,
    'toctree_titles_only': True,
    'globaltoc_expand_depth': 1,
}

html_context = {
    'source_type': 'github',
    'source_user': 'jonaslindemann',
    'source_repo': 'modern_fortran_book',
    'source_version': 'master',
    'source_docs_path': '/docs/source/',
}

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
html_static_path = ['_static']

html_css_files = ['custom.css']

# -- Options for LaTeX output ------------------------------------------------

latex_elements = {
    'papersize': 'c5paper',
    'pointsize': '10pt'
}
