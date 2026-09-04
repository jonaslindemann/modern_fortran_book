.. Modern Fortran in Science and Technology documentation master file, created by
   sphinx-quickstart on Wed Sep  2 17:21:23 2020.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

===================================================
Modern Fortran in Science and Technology
===================================================

.. Cover image, swapped by colour mode. Shibuya puts a "light" or "dark"
   class on <html>, and its stylesheet already hides `.dark-only` under
   `.light` and `.light-only` under `.dark`, so no extra CSS is needed.

.. image:: images/fortran_cover_light.png
   :width: 100.0%
   :alt: Modern Fortran in Science and Technology
   :class: light-only

.. image:: images/fortran_cover_dark.png
   :width: 100.0%
   :alt: Modern Fortran in Science and Technology
   :class: dark-only

Authors: Jonas Lindemann and Ola Dahlblom

This book is an introduction to programming with Fortran 95/2003/2008/2018 in science and technology. It covers the language itself, from a first program to object-oriented programming, and parallel programming with do concurrent, OpenMP and coarrays. It also covers methods for calling Fortran from Python and for combining it with C, building larger projects with Make, CMake and fpm, and working in modern development environments such as Visual Studio Code and Qt Creator.

.. note:: 

   This book has been developed and refined with the assistance of AI language models,  which helped modernize code examples to current Fortran standards, improve explanations for clarity, and ensure consistency throughout the material. 

   All content, examples, and technical recommendations have been reviewed and validated for accuracy and alignment with current industry practices.

.. toctree::
   :caption: Contents:
   :maxdepth: 1
   :hidden:

   chapter_getting_started
   chapter_fortran
   chapter_parallel
   chapter_fortran_python
   chapter_fortran_projects
   chapter_vscode
   chapter_qtcreator
   app_exercises
   app_compiling_fortran
   references


Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
