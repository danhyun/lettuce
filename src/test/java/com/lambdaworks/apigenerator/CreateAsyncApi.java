package com.lambdaworks.apigenerator;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.function.Consumer;
import java.util.function.Function;
import java.util.function.Supplier;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;

import com.github.javaparser.ast.CompilationUnit;
import com.github.javaparser.ast.ImportDeclaration;
import com.github.javaparser.ast.body.ClassOrInterfaceDeclaration;
import com.github.javaparser.ast.body.MethodDeclaration;
import com.github.javaparser.ast.expr.NameExpr;
import com.github.javaparser.ast.type.ClassOrInterfaceType;
import com.github.javaparser.ast.type.ReferenceType;
import com.github.javaparser.ast.type.Type;
import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableSet;
import com.google.common.collect.Lists;

/**
 * Create async API based on the templates.
 *
 * @author <a href="mailto:mpaluch@paluch.biz">Mark Paluch</a>
 */
@RunWith(Parameterized.class)
public class CreateAsyncApi {

    private Set<String> KEEP_METHOD_RESULT_TYPE = ImmutableSet.of("shutdown", "debugOom", "debugSegfault", "digest", "close",
            "isOpen", "BaseRedisCommands.reset", "getStatefulConnection");

    private CompilationUnitFactory factory;

    @Parameterized.Parameters(name = "Create {0}")
    public static List<Object[]> arguments() {
        List<Object[]> result = Lists.newArrayList();

        for (String templateName : Constants.TEMPLATE_NAMES) {
            result.add(new Object[] { templateName });
        }

        return result;
    }

    /**
     * @param templateName
     */
    public CreateAsyncApi(String templateName) {

        String targetName = templateName.replace("Commands", "AsyncCommands");

        File templateFile = new File(Constants.TEMPLATES, "com/lambdaworks/redis/api/" + templateName + ".java");
        String targetPackage;

        if (templateName.contains("RedisSentinel")) {
            targetPackage = "com.lambdaworks.redis.sentinel.api.async";
        } else {
            targetPackage = "com.lambdaworks.redis.api.async";
        }

        factory = new CompilationUnitFactory(templateFile, Constants.SOURCES, targetPackage, targetName, commentMutator(),
                methodTypeMutator(), methodDeclaration -> true, importSupplier(), typeMutator(), null);
    }

    private Consumer<ClassOrInterfaceDeclaration> typeMutator() {
        return type -> {

            if (type.getName().contains("SentinelAsyncCommands")) {
                type.getExtends().add(new ClassOrInterfaceType("RedisSentinelAsyncConnection<K, V>"));
                CompilationUnit compilationUnit = (CompilationUnit) type.getParentNode();
                if (compilationUnit.getImports() == null) {
                    compilationUnit.setImports(new ArrayList<>());
                }
                compilationUnit.getImports()
                        .add(new ImportDeclaration(new NameExpr("com.lambdaworks.redis.RedisSentinelAsyncConnection"), false,
                                false));
            }

        };
    }

    /**
     * Mutate type comment.
     *
     * @return
     */
    protected Function<String, String> commentMutator() {
        return s -> s.replaceAll("\\$\\{intent\\}", "Asynchronous executed commands") + "* @generated by "
                + getClass().getName() + "\r\n ";
    }

    /**
     * Mutate type to async result.
     *
     * @return
     */
    protected Function<MethodDeclaration, Type> methodTypeMutator() {
        return method -> {
            ClassOrInterfaceDeclaration classOfMethod = (ClassOrInterfaceDeclaration) method.getParentNode();
            if (KEEP_METHOD_RESULT_TYPE.contains(method.getName())
                    || KEEP_METHOD_RESULT_TYPE.contains(classOfMethod.getName() + "." + method.getName())) {
                return method.getType();
            }

            String typeAsString = method.getType().toStringWithoutComments().trim();
            if (typeAsString.equals("void")) {
                typeAsString = "Void";
            }

            return new ReferenceType(new ClassOrInterfaceType("RedisFuture<" + typeAsString + ">"));
        };
    }

    /**
     * Supply addititional imports.
     *
     * @return
     */
    protected Supplier<List<String>> importSupplier() {
        return () -> ImmutableList.of("com.lambdaworks.redis.RedisFuture");
    }

    @Test
    public void createInterface() throws Exception {
        factory.createInterface();
    }
}
