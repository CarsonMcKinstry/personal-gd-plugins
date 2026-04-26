import archiver from 'archiver';
import { createWriteStream, existsSync } from 'fs';
import fs from 'fs/promises';
import path from 'path';

const srcDirectory = path.join(import.meta.dirname, '../src');
const archiveDirectory = path.join(import.meta.dirname, '../archives');
const configFileName = "plugin.cfg";

const getAddonDirectories = async () => {
  const dirs = await fs.readdir(srcDirectory, { withFileTypes: true });

  return [...dirs]
    .filter(dir => dir.isDirectory());
}

const makeArchiveDirectory = async () => {
  if (!existsSync(archiveDirectory)) {
    await fs.mkdir(archiveDirectory);
  }
}

const getVersion = async (addonName: string) => {
  const configPath = path.join(srcDirectory, addonName, configFileName);
  const versionRegex = /(?<=version=")(?<versionNumber>.+)(?=")/
  const file = await fs.readFile(configPath, "utf-8");
  return versionRegex.exec(file)?.groups?.['versionNumber'];
}

const getAddonPath = (addonName: string) => path.join(srcDirectory, addonName);

const getArchiveName = async (addonName: string) => {
  const versionNumber = await getVersion(addonName);

  return `${addonName}-${versionNumber}.zip`;
}

const zipPlugin = (addonName: string) => new Promise(async (res, rej) => {

  const archiveName = await getArchiveName(addonName);
  const archivePath = path.join(archiveDirectory, archiveName);
  const addonPath = getAddonPath(addonName);

  const output = createWriteStream(archivePath);
  const archive = archiver('zip');


  output.on("close", res);
  output.on('error', rej);

  archive.pipe(output);

  archive.directory(
    addonPath,
    path.join(addonName,"addons")
  );

  archive.finalize();
});

(async function main() {

  await makeArchiveDirectory();

  const pluginDirectories = await getAddonDirectories();

  for (const directory of pluginDirectories) {
    await zipPlugin(directory.name);
  }

})();