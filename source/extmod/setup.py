from numpy.distutils.core import setup, Extension

setup(
	ext_modules = [
		Extension("cext", 
			sources=["cext.c"]),
		Extension("fext",
			sources=["fext.c"], 
			extra_objects=["forsum.o"])
	]
)
