import java.io.IOException;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.Iterator;
import java.util.List;
import java.util.ArrayList;

import org.jruby.Ruby;
import org.jruby.RubyArray;
import org.jruby.RubyClass;
import org.jruby.RubyModule;
import org.jruby.anno.JRubyMethod;
import org.jruby.IncludedModuleWrapper;
import org.jruby.runtime.Block;
import org.jruby.runtime.builtin.IRubyObject;
import org.jruby.exceptions.RaiseException;
import org.jruby.runtime.load.BasicLibraryService;

public class MixologyService implements BasicLibraryService {
    public boolean basicLoad(final Ruby runtime) throws IOException {
        RubyModule mixologyModule = runtime.defineModule("Mixology");
        mixologyModule.defineAnnotatedMethods(MixologyService.class);
	    runtime.getObject().includeModule(mixologyModule);
        return true;
    }
    

    @JRubyMethod(name = "unmix", required = 1)
    public synchronized static IRubyObject unmix(IRubyObject recv, IRubyObject _module, Block block) 
			throws NoSuchMethodException, IllegalAccessException, InvocationTargetException {
		RubyModule module = (RubyModule)_module;
        for (RubyModule klass = recv.getMetaClass(); klass != recv.getMetaClass().getRealClass(); klass = klass.getSuperClass()) {
            if (klass.getSuperClass() != null &&  klass.getSuperClass().getNonIncludedClass() == module) {
						  if(module.getSuperClass() != null && module.getSuperClass() instanceof IncludedModuleWrapper) 
								remove_nested_module(klass.getSuperClass(), module);
									setSuperClass(klass, klass.getSuperClass().getSuperClass());
                  clearCacheMap(klass, module);
						}
        }

        return recv;

    }

        @JRubyMethod(name = "mixin", required = 1)
		public synchronized static IRubyObject mixin(IRubyObject recv, IRubyObject _module, Block block) 
			throws NoSuchMethodException, IllegalAccessException, InvocationTargetException {
		RubyModule module = (RubyModule)_module;
      	unmix(recv, module, block);

			RubyClass klass = recv.getSingletonClass();

      int nestedModuleCount = 0;
			for (RubyModule p = module.getSuperClass(); p != null; p = p.getSuperClass()) 
				nestedModuleCount++;

			IncludedModuleWrapper[] nestedModules = new IncludedModuleWrapper[nestedModuleCount];

   		IncludedModuleWrapper nestedModule = (IncludedModuleWrapper)module.getSuperClass();
			for(int index = 0; index < nestedModules.length; index++){
				nestedModules[index] = nestedModule;
				nestedModule =  (IncludedModuleWrapper)nestedModule.getSuperClass();
			}

		  for(int index = nestedModules.length; index > 0; index--) {
		      add_module(klass, nestedModules[index-1].getNonIncludedClass());
		  }

				add_module(klass, module);
        clearCache(klass, klass.getSuperClass());

				return recv;
		}

		protected synchronized static void add_module(RubyClass klass, RubyModule module) 
			throws NoSuchMethodException, IllegalAccessException, InvocationTargetException {

        klass.infectBy(module);
				
				IncludedModuleWrapper includedKlass = new IncludedModuleWrapper(klass.getRuntime(), klass.getSuperClass(), module);
				
        setSuperClass(klass, includedKlass);

        clearCache(klass, klass.getSuperClass());
    }

		protected synchronized static void remove_nested_module(RubyClass klass, RubyModule include_class) 
			throws NoSuchMethodException, IllegalAccessException, InvocationTargetException {
	
				if(! (klass.getSuperClass() instanceof IncludedModuleWrapper) ||
				 ((IncludedModuleWrapper)klass.getSuperClass()).getNonIncludedClass() != ((IncludedModuleWrapper)include_class.getSuperClass()).getNonIncludedClass()) 
					return;
					
	
				if(include_class.getSuperClass().getSuperClass() != null && include_class.getSuperClass() instanceof IncludedModuleWrapper) {
						remove_nested_module(klass.getSuperClass(), include_class.getSuperClass());
  			}
      
 				setSuperClass(klass, klass.getSuperClass().getSuperClass());

		}

		protected synchronized static void setSuperClass(RubyModule klass, RubyModule superClass)
			throws NoSuchMethodException, IllegalAccessException, InvocationTargetException {
				Method method = RubyModule.class.getDeclaredMethod("setSuperClass", new Class[] {RubyClass.class} );
				method.setAccessible(true);
				Object[] superClassArg = new Object[] { superClass };
				method.invoke(klass, superClassArg);
		}

    protected static void clearCache(RubyModule klass, RubyModule module) {
        List<String> methodNames = new ArrayList<String>(module.getMethods().keySet());
        for (Iterator iter = methodNames.iterator(); iter.hasNext();) {
            String methodName = (String) iter.next();
            klass.getRuntime().getConstantCacheMap().remove(klass.searchMethod(methodName));
        }
    }
}
