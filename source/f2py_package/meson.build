project('fmatrix', 'c', 'fortran', version: '0.1.0')

py = import('python').find_installation(pure: false)

incdir_numpy = run_command(py,
  ['-c', 'import numpy; print(numpy.get_include())'],
  check: true
).stdout().strip()

incdir_f2py = run_command(py,
  ['-c', 'import numpy.f2py; print(numpy.f2py.get_include())'],
  check: true
).stdout().strip()

fmatrix_wrappers = custom_target('fmatrixmodule.c',
  input: ['src/fmatrix.f90'],
  output: ['fmatrixmodule.c', 'fmatrix-f2pywrappers2.f90'],
  command: [py, '-m', 'numpy.f2py', '@INPUT@', '-m', 'fmatrix', '--lower',
            '--build-dir', '@OUTDIR@']
)

link_args = []
if host_machine.system() == 'windows'
  link_args += ['-static']
endif

py.extension_module('fmatrix',
  ['src/fmatrix.f90', fmatrix_wrappers, incdir_f2py / 'fortranobject.c'],
  include_directories: include_directories(incdir_numpy, incdir_f2py),
  dependencies: py.dependency(),
  link_args: link_args,
  install: true
)
