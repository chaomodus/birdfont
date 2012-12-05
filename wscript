import time;

VERSION = '0.6'
APPNAME = 'birdfont'

top = '.'
out = 'build'

def options(opt):
	opt.load('compiler_c')
	opt.load('vala')
	opt.add_option('--win32', action='store_true', default=False, help='Crosscompile for Windows')
	opt.add_option('--installer', action='store_true', default=False, help='Create Windows installer')
	opt.add_option('--noconfig', action='store_true', default=False, help="Don't write Config.vala")
        
def configure(conf):
	conf.load('compiler_c vala')
	conf.check_vala(min_version=(0,17,3))
	
	conf.check_cfg(package='cairo', uselib_store='CAIRO', mandatory=1, args='--cflags --libs')
	conf.check_cfg(package='gdk-pixbuf-2.0',  uselib_store='PIXBUF', mandatory=1, args='--cflags --libs')
	conf.check_cfg(package='gio-2.0',  uselib_store='GIO', atleast_version='2.16.0', mandatory=1, args='--cflags --libs')
	conf.check_cfg(package='glib-2.0', uselib_store='GLIB',atleast_version='2.16.0', mandatory=1, args='--cflags --libs')
	conf.check_cfg(package='gtk+-2.0', uselib_store='GTK', atleast_version='2.16.0', mandatory=1, args='--cflags --libs')
	conf.check_cfg(package='libxml-2.0', uselib_store='XML', mandatory=1, args='--cflags --libs')
	conf.check_cfg(package='webkit-1.0', uselib_store='WEB', mandatory=1, args='--cflags --libs')
	conf.check_cfg(package='libsoup-2.4', uselib_store='SOUP', mandatory=1, args='--cflags --libs')
	
	conf.env.append_unique('VALAFLAGS', ['--thread', '--pkg', 'webkit-1.0', '--enable-experimental', '--enable-experimental-non-null', '--vapidir=../../'])

	conf.find_program('ldconfig', var='LDCONFIG', mandatory=False)

	conf.define('GETTEXT_PACKAGE', 'birdfont')

	if conf.options.win32 :
		conf.recurse('win32')

def pre (bld):
	bld.env.VERSION = VERSION
	
	if not bld.options.noconfig:
		write_config (bld)

def post (bld):
	bld.exec_command ('${LDCONFIG}')
				
def build(bld):
	bld.env.VERSION = VERSION
	
	bld.add_pre_fun(pre)
	bld.add_post_fun(post)
	
	bld.recurse('src')

	start_dir = bld.path.find_dir('./')
	bld.install_files('${PREFIX}/share/birdfont/', start_dir.ant_glob('layout/*'), cwd=start_dir, relative_trick=True)
	bld.install_files('${PREFIX}/share/birdfont/', start_dir.ant_glob('icons/*'), cwd=start_dir, relative_trick=True)
	
	bld.install_files('${PREFIX}/share/applications/', ['linux/birdfont.desktop'])
	bld.install_files('${PREFIX}/share/icons/hicolor/48x48/apps/', ['linux/birdfont.png'])

	if bld.options.win32:
		bld.recurse('win32')
		
def write_config (cfg):
	print ("Writing Config.vala")	

	f = open('./src/Config.vala', 'w+')
	f.write("// Don't edit this file – it's generated by wscript\n")
	f.write("namespace Supplement {\n")
	
	f.write("	internal static const string VERSION = \"")
	f.write(VERSION)
	f.write("\"");
	f.write(";\n")

	localtime = time.asctime( time.localtime(time.time()))
	
	f.write("	internal static const string BUILD_TIMESTAMP = \"")
	f.write(localtime)
	f.write("\"");
	f.write(";\n")

	f.write("	internal static const string PREFIX = \"")
	f.write(cfg.options.prefix)
	f.write("\"");
	f.write(";\n")
			
	f.write("}");
