const path = require("path");
const autoprefixer = require("autoprefixer");

module.exports = [
  {
    resolve: {
      modules: [
        path.resolve(__dirname, "project_name/static/js"),
        "node_modules",
      ],
    },
    mode: "production",
    entry: "bundle.js",
    output: {
      path: path.resolve(__dirname, "project_name/static/"),
      filename: "bundle.js",
    },
  },
  {
    module: {
      rules: [
        {
          test: /\.scss$/,
          use: [
            {
              loader: "postcss-loader",
              options: {
                postcssOptions: { plugins: [autoprefixer()] },
              },
            },
            {
              loader: "sass-loader",
              options: {
                sassOptions: {
                  includePaths: [
                    path.resolve(__dirname, "my_data_chameleon/static/scss/"),
                  ],
                },
              },
            },
          ],
          type: "asset",
        },
      ],
    },
    resolve: {
      modules: [path.resolve(__dirname, "my_data_chameleon/static/scss/")],
    },
    mode: "production",
    entry: "bundle.scss",
    output: {
      path: path.resolve(__dirname, "my_data_chameleon/static/"),
      filename: "bundle.css.js",
      assetModuleFilename: "bundle.css",
    },
  },
];
