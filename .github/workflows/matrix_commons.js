//
//    __                          __
//   / /____ ___ ____  ___  ___ _/ /       This file is provided to you by https://github.com/tegonal/github-commons
//  / __/ -_) _ `/ _ \/ _ \/ _ `/ /        Copyright 2022 Tegonal Genossenschaft <info@tegonal.com>
//  \__/\__/\_, /\___/_//_/\_,_/_/         It is licensed under Apache License 2.0
//         /___/                           Please report bugs and contribute back your improvements
//
//                                         Version: v2.4.0-SNAPSHOT
//##################################
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# DO NOT MODIFY HERE BUT IN src/.github/workflows/matrix_commons.js
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// adapted version of https://github.com/vlsi/github-actions-random-matrix/blob/main/examples/matrix.js
// licensed under Apache License 2.0
//##################################
const os = require("os");
const fs = require("fs");

const javaDistributionAxis = {
	name: 'java_distribution',
	values: [
		'corretto',
		'liberica',
		'microsoft',
		'semeru',
		'temurin',
		'zulu',
	]
};

const javaVersionAxis = javaVersionAxisBuilder(['11', '17', '21']);

function javaVersionAxisBuilder(values){
	return {
		name: 'java_version',
		title: x => 'Java ' + x,
		values: values
	}
}

const osAxis = {
	name: 'os',
	title: x => x.replace('-latest', ''),
	values: [
		'ubuntu-latest',
		'windows-latest',
		'macos-latest'
	]
}

// see https://github.com/actions/toolkit/issues/1218
function setOutput(key, value) {
	// Temporary hack until core actions library catches up with github new recommendations
	const output = process.env['GITHUB_OUTPUT']
	if (output !== undefined){
		fs.appendFileSync(output, `${key}=${value}${os.EOL}`)
	} else{
		console.log('::set-output name=' + key + '::' + value);
	}
}

function setMatrix(matrix, numberOfJobs) {
	const include = matrix.generateRows(process.env.MATRIX_JOBS || numberOfJobs);
	if (include.length === 0) {
		throw new Error('Matrix list is empty');
	}

	// Sort jobs by name, however, numeric parts are sorted appropriately
	// For instance, 'windows 8' would come before 'windows 11'
	include.sort((a, b) => a.name.localeCompare(b.name, undefined, {numeric: true}));

	console.log(include);
	setOutput('matrix', JSON.stringify({include}));
}

function configureKotlinDefaults(matrix) {
	const kotlinJavaDistributionAxis = {
		...javaDistributionAxis,
		values: javaDistributionAxis.values.filter ( x =>
			// seems to have problems with kotlin https://youtrack.jetbrains.com/issue/KT-61836
			x != 'semeru'
		)
	};

	matrix.addAxis(kotlinJavaDistributionAxis);
	matrix.addAxis(javaVersionAxis);
	matrix.addAxis(osAxis);

	// This specifies the order of axes in CI job name (individual titles would be joined with a comma)
	matrix.setNamePattern(['java_version', 'java_distribution', 'os']);

	// generate one with oldest java and one with newest java version
	matrix.generateRow({java_version: matrix.axisByName.java_version.values[0]});
	matrix.generateRow({java_version: matrix.axisByName.java_version.values.slice(-1)[0]});
	matrix.generateRow({os: 'ubuntu-latest'});
	matrix.generateRow({os: 'windows-latest'});
}

module.exports = { javaDistributionAxis, javaVersionAxis, osAxis, setMatrix, configureKotlinDefaults };
