# r_package_template

Template repository for lab R Packages.

## How to Use

1. Create a new repository using this template.
    1. Click the “Use this template” button to create a new repository.
    2. Name your repository to be the name of your R package.
2. Clone your newly created repository to your local machine.
3. Rename the `r_package_template.Rproj` file to based on the package name.
4. Update the `DESCRIPTION` file with the package's name, title, and description.
5. Update the `README.md` file by deleting everything above `# {PACKAGE_NAME}`, replacing all instances of `{PACKAGE_NAME}` with the package name, and replacing "is a very useful package" with a concise description of what the package does.
6. Download the GitHub Actions workflow files by sourcing download_actions_workflows.R.
7. Replace/delete the various example code/files as you develop your package!

# {PACKAGE_NAME}

[![check-deploy](https://github.com/hugheylab/{PACKAGE_NAME}/workflows/check-deploy/badge.svg)](https://github.com/hugheylab/{PACKAGE_NAME}/actions)
[![codecov](https://codecov.io/gh/hugheylab/{PACKAGE_NAME}/branch/master/graph/badge.svg)](https://codecov.io/gh/hugheylab/{PACKAGE_NAME})
[![drat version](https://raw.githubusercontent.com/hugheylab/drat/gh-pages/badges/{PACKAGE_NAME}_drat_badge.svg)](https://github.com/hugheylab/drat/tree/gh-pages/src/contrib)

`{PACKAGE_NAME}` is a very useful package.

## Installation

### Option 1: CRAN

```r
install.packages('{PACKAGE_NAME}')
```

### Option 2: Hughey Lab Drat Repository

1. Install [`BiocManager`](https://cran.r-project.org/package=BiocManager).

    ```r
    if (!requireNamespace('BiocManager', quietly = TRUE))
      install.packages('BiocManager')
    ```

1. If you use RStudio, go to Tools → Global Options... → Packages → Add... (under Secondary repositories), then enter:

    - Name: hugheylab
    - Url: https://hugheylab.github.io/drat/

    You only have to do this once. Then you can install or update the package by entering:

    ```r
    BiocManager::install('{PACKAGE_NAME}')
    ```

    Alternatively, you can install or update the package by entering:

    ```r
    BiocManager::install('{PACKAGE_NAME}', site_repository = 'https://hugheylab.github.io/drat/')
    ```

## Usage

See the examples and detailed guidance in the [reference documentation](https://{PACKAGE_NAME}.hugheylab.org/reference/index.html).
