from traceback import format_exc
from aiohttp import ClientSession
from vidmergebot import LOGGER
from vidmergebot.utils.display_progress import humanbytes
from vidmergebot.utils.ikb import ikb
from vidmergebot.vars import Vars

async def shorten_url(long_url: str):
    api_url = f"https://tinyurl.com/api-create.php?url={long_url}"
    async with ClientSession() as sess:
        async with sess.get(api_url) as resp:
            short_url = await resp.text()
    return short_url

async def upload_to_streamtape(output_vid: str):
    async with ClientSession() as session:
        hit_api = await session.get(
            f"https://api.streamtape.com/file/ul?login={Vars.STREAMTAPE_API_USERNAME}&key={Vars.STREAMTAPE_API_PASS}",
        )
        json_data = await hit_api.json()
        
        # Check if the API response contains the expected data
        if "result" not in json_data or "url" not in json_data["result"]:
            LOGGER.error(f"Failed to get upload URL: {json_data}")
            raise ValueError("Upload failed, no result returned.")
        
        temp_api = json_data["result"]["url"]
        
        # Use a context manager to ensure the file is properly opened
        with open(output_vid, "rb") as file:
            files = {"file1": file}
            response = await session.post(temp_api, data=files)
            data_f = await response.json(content_type=None)

            # Check if the response contains a valid download link
            if "result" not in data_f or "url" not in data_f["result"]:
                LOGGER.error(f"Upload failed: {data_f}")
                raise ValueError("Upload failed, no result returned.")
                
            download_link = data_f["result"]["url"]
            filename = output_vid.split("/")[-1].replace("_", " ")
            return (await shorten_url(download_link)), filename

async def streamtape_upload(editable, outfile_name, file_size, video_thumbnail):
    download_link = ""
    await editable.edit_text(
        f"<b>File Size:</b> {humanbytes(file_size)}\n"
        "Uploading file to StreamTape...!",
    )
    try:
        download_link, filename = await upload_to_streamtape(
            output_vid=outfile_name,
        )
        
        # Check if video_thumbnail is valid
        if video_thumbnail is None:
            LOGGER.error("Video thumbnail is None.")
            await editable.edit("Error: Video thumbnail is not available.")
            return
        
        text_edit = (
            "<b>File Uploaded to Streamtape!</b>\n\n"
            f"<b>File Name:</b> <code>{filename}</code>\n"
            f"<b>Size:</b> <code>{humanbytes(file_size)}</code>\n"
            f"<b>Link:</b> {download_link}"
        )
        
        await editable.reply_photo(
            video_thumbnail,
            caption=text_edit,
            reply_markup=ikb([[("Open Link", download_link, "url")]]),
        )
    except Exception as ef:
        LOGGER.error(f"Error: {ef}")
        LOGGER.error(format_exc())
        await editable.edit(
            f"Something went wrong!\n\nCan't Upload to Streamtape. You can report at [Support Group](https://t.me/{Vars.SUPPORT_GROUP})",
        )

    return download_link
