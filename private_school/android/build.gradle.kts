buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Met à jour le plugin Android Gradle
        classpath("com.android.tools.build:gradle:8.11.1")
        // Met à jour Kotlin à 2.1.0 minimum
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.1.0")

    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Déplace le build dir pour tout le projet (utile pour CI/CD)
val newBuildDir: Directory =
    rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

// Tâche clean
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
