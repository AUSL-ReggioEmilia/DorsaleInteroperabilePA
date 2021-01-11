const path = require('path');

module.exports = {
    mode:'production',
    entry: './wwwroot/ts/main.ts',
    output: {
        filename: 'main.bundle.js',
        path: path.join(__dirname, 'wwwroot/js')
    },
    externals: {
        jquery: 'jQuery',
        moment: 'moment',
        fullcalendar: 'FullCalendar'
    },
    devtool: 'sourcemap',
	resolve: {
		mainFiles: ['main.ts'],
        extensions: ['.ts', '.js']
    },
    module: {
		rules: [
			{ test: /\.tsx?$/, loader: 'awesome-typescript-loader', options: { onlyCompileBundledFiles: true }},
            { enforce: 'pre', test: /\.js$/, loader: 'source-map-loader' },
            { test: /\.css$/, use: ['style-loader', 'css-loader'] },
            { test: /\.(woff|woff2|eot|ttf)$/, loader: 'url-loader' },
            { test: /\.(png|jpg|gif|svg)$/i,use: ['url-loader']}

        ]
    }
};