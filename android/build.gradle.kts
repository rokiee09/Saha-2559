allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// Isar (isar_flutter_libs 3.1.0+1) gibi eski Flutter eklentileri, AGP 8'in zorunlu
// kıldığı "namespace" değerini tanımlamaz ve "Namespace not specified" hatası verir.
// Eklenti (com.android.library) uygulandığı anda, namespace'i olmayan modüllere
// group değerine göre (ör. dev.isar.isar_flutter_libs) namespace enjekte ediyoruz.
// Böylece AGP'yi düşürmeye gerek kalmadan uyumsuzluk giderilir.
subprojects {
    plugins.withId("com.android.library") {
        val androidExt = extensions.findByName("android") ?: return@withId
        val getNamespace = androidExt.javaClass.methods
            .firstOrNull { it.name == "getNamespace" && it.parameterCount == 0 }
        val setNamespace = androidExt.javaClass.methods
            .firstOrNull { it.name == "setNamespace" && it.parameterCount == 1 }
        if (getNamespace != null && setNamespace != null) {
            val current = getNamespace.invoke(androidExt) as? String
            if (current.isNullOrBlank()) {
                val fallback = project.group.toString()
                    .ifBlank { "fixed.namespace.${project.name.replace('-', '_')}" }
                setNamespace.invoke(androidExt, fallback)
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
