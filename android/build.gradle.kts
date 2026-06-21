allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

subprojects {
    afterEvaluate {
        if (plugins.hasPlugin("com.android.library")) {
            extensions.findByType(com.android.build.gradle.LibraryExtension::class.java)?.apply {
                if (namespace.isNullOrBlank()) {
                    val manifestFile = file("src/main/AndroidManifest.xml")
                    if (manifestFile.exists()) {
                        val manifest = groovy.util.XmlParser().parse(manifestFile)
                        val packageName = manifest.attribute("package")?.toString()
                        if (!packageName.isNullOrBlank()) {
                            namespace = packageName
                        }
                    }
                }
            }
        }
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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
